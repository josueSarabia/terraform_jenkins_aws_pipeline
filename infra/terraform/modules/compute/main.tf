data "aws_ami" "ubuntu" {
  most_recent = "true"

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "web_server" {
  count                  = length(var.public_subnets)
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnets[count.index].id
  vpc_security_group_ids = var.web_security_groups
  associate_public_ip_address = true
  key_name = "devops"

  user_data = <<-EOF
  #!/bin/bash
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install docker-ce docker-ce-cli containerd.io docker-compose-plugin
  sudo usermod -aG docker ubuntu

  cd ~
  wget https://aws-codedeploy-${var.region}.s3.${var.region}.amazonaws.com/latest/install
  chmod +x ./install
  sudo ./install auto > /tmp/logfile
  EOF


  iam_instance_profile = var.web_instance_profile
  
  tags = {
    Name = "${var.environment}-webserver"
  }
}