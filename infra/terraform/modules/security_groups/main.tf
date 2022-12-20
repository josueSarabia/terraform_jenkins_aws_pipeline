resource "aws_security_group" "app_lb_sg" {
  name = "Security Group for application load balancer"
  vpc_id = var.vpc_id

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
    Name = "app_lb_sg"
  }
}

resource "aws_security_group" "ec2_sg_public_subnet" {
  name = "Security Group for EC2 instances in public subnets"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      security_groups = [aws_security_group.app_lb_sg.id]
    }
  }

  ingress {
    description = "Allow connection from prometheus server"
    from_port = "9100"
    to_port = "9100"
    protocol = "tcp"
    cidr_blocks = [var.prometheus_sg_id]
  }

  ingress {
    description = "Allow SSH from my computer"
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "prod-ec2-sg-public-subnet"
  }
}

resource "aws_security_group" "ec2_staging_sg_public_subnet" {
  name = "Security Group for EC2 instances in public subnets"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress {
    description = "Allow connection from prometheus server"
    from_port = "9100"
    to_port = "9100"
    protocol = "tcp"
    cidr_blocks = [var.prometheus_sg_id]
  }

  ingress {
    description = "Allow SSH from my computer"
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "staging-ec2-sg-public-subnet"
  }
}