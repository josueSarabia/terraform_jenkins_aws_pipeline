data "aws_availability_zones" "availability_zone" {}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  instance_tenancy = "default"

  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_subnet" "public" {
  # count = var.environment != "jenkins" ? length(var.public_subnets) : 1
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
  # count = var.environment != "jenkins" ? length(var.public_subnets) : 1
  count = length(var.public_subnets)
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id

  depends_on = [aws_subnet.public, aws_route_table.public]
}

