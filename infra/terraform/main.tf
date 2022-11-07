provider "aws" {
  region  = var.region
  # profile = var.profile
}

#----------------------- networking --------------------------

data "aws_availability_zones" "availability_zone" {}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  instance_tenancy = "default"

  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_subnet" "public" {
    count = length(var.public_subnets)
    cidr_block = tolist(var.public_subnets)[count.index]
    vpc_id = aws_vpc.main.id

    availability_zone = data.aws_availability_zones.availability_zone.names[count.index]

    tags = {
        Name        = "${var.environment}-publicsubnet-${count.index + 1}"
        AZ          = data.aws_availability_zones.availability_zone.names[count.index]
        Environment = "${var.environment}-publicsubnet"
    }
    depends_on = [aws_vpc.main]
}

resource "aws_internet_gateway" "internetgateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-InternetGateway"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internetgateway.id
  }

  tags = {
    Name = "${var.environment}-publicroutetable"
  }

  depends_on = [aws_internet_gateway.internetgateway]
}


resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id

  depends_on = [aws_subnet.public, aws_route_table.public]
}

# ------------------------- end networking ------------------------------

# ------------------------- instances -----------------------------------


resource "aws_instance" "web_server" {
  count                  = length(var.public_subnets)
  ami                    = "ami-08c40ec9ead489470"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.ec2_sg_public_subnet.id]


  tags = {
    Name = "${var.environment}-webserver"
  }
}

resource "aws_security_group" "ec2_sg_public_subnet" {
  name = "Security Group for EC2 instances in public subnets"
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      security_groups = [aws_security_group.app_lb_sg.id]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-ec2-sg-public-subnet"
  }
  depends_on = [aws_vpc.main]
}


# ------------------------- end instances -----------------------------------


# -------------------------------- app load balancer ------------------------

resource "aws_security_group" "app_lb_sg" {
  name = "Security Group for application load balancer"
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-app_lb_sg"
  }
  depends_on = [aws_vpc.main]
}


resource "aws_alb" "main" {
  name            = "${var.app_name}-${var.environment}-lb"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.app_lb_sg.id]
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.main.id
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app.id
    type             = "forward"
  }
}

resource "aws_alb_target_group" "app" {
  name        = "${var.app_name}-${var.environment}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    healthy_threshold = "3"
    interval          = "30"
    protocol          = "HTTP"
    matcher           = "200"
    timeout           = "3"
    unhealthy_threshold = "2"
  }
}

resource "aws_lb_target_group_attachment" "alb_tg_attachment" {
  target_group_arn = aws_alb_target_group.app.arn
  port      = 80
  count     = length(aws_instance.web_server)
  target_id = aws_instance.web_server[count.index].id
}

# -------------------------- end app load balancer -------------------------


# ------------------------ aws ecr ------------------------

/* resource "aws_ecr_repository" "front_end" {
  name                 = "front_end"
} */

