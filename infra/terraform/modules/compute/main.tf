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

  USER_HOME="/home/ubuntu"
  ARTIFACT_NAME="monitoring"

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


  sudo apt-get install ruby-full ruby-webrick wget -y
  cd /tmp
  wget https://aws-codedeploy-${var.region}.s3.${var.region}.amazonaws.com/releases/codedeploy-agent_1.3.2-1902_all.deb
  mkdir codedeploy-agent_1.3.2-1902_ubuntu22
  dpkg-deb -R codedeploy-agent_1.3.2-1902_all.deb codedeploy-agent_1.3.2-1902_ubuntu22
  sed 's/Depends:.*/Depends:ruby3.0/' -i ./codedeploy-agent_1.3.2-1902_ubuntu22/DEBIAN/control
  dpkg-deb -b codedeploy-agent_1.3.2-1902_ubuntu22/
  sudo dpkg -i codedeploy-agent_1.3.2-1902_ubuntu22.deb
  sudo systemctl list-units --type=service | grep codedeploy
  sudo service codedeploy-agent status

  aws s3 cp s3://${var.bucket_name}/$ARTIFACT_NAME.tar.gz $USER_HOME/$ARTIFACT_NAME.tar.gz
  tar -xf $USER_HOME/$ARTIFACT_NAME.tar.gz -C $USER_HOME/
  sudo chown -R ubuntu:ubuntu $USER_HOME/$ARTIFACT_NAME

  docker compose -f ./$ARTIFACT_NAME/exporters/docker-compose.yml up -d

  EOF


  iam_instance_profile = var.web_instance_profile
  
  tags = {
    Name = "webserver"
  }
}

resource "aws_instance" "web_server_staging" {
  count                  = 1
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnets[count.index].id
  vpc_security_group_ids = var.web_staging_security_groups
  associate_public_ip_address = true
  key_name = "devops"

  user_data = <<-EOF
  #!/bin/bash

  USER_HOME="/home/ubuntu"
  ARTIFACT_NAME="monitoring"

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


  sudo apt-get install ruby-full ruby-webrick wget -y
  cd /tmp
  wget https://aws-codedeploy-${var.region}.s3.${var.region}.amazonaws.com/releases/codedeploy-agent_1.3.2-1902_all.deb
  mkdir codedeploy-agent_1.3.2-1902_ubuntu22
  dpkg-deb -R codedeploy-agent_1.3.2-1902_all.deb codedeploy-agent_1.3.2-1902_ubuntu22
  sed 's/Depends:.*/Depends:ruby3.0/' -i ./codedeploy-agent_1.3.2-1902_ubuntu22/DEBIAN/control
  dpkg-deb -b codedeploy-agent_1.3.2-1902_ubuntu22/
  sudo dpkg -i codedeploy-agent_1.3.2-1902_ubuntu22.deb
  sudo systemctl list-units --type=service | grep codedeploy
  sudo service codedeploy-agent status

  aws s3 cp s3://${var.bucket_name}/$ARTIFACT_NAME.tar.gz $USER_HOME/$ARTIFACT_NAME.tar.gz
  tar -xf $USER_HOME/$ARTIFACT_NAME.tar.gz -C $USER_HOME/
  sudo chown -R ubuntu:ubuntu $USER_HOME/$ARTIFACT_NAME

  docker compose -f ./$ARTIFACT_NAME/exporters/docker-compose.yml up -d

  EOF


  iam_instance_profile = var.web_instance_profile
  
  tags = {
    Name = "staging-webserver"
  }
}