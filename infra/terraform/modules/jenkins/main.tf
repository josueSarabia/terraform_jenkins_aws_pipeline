data "aws_iam_policy" "aws_code_deploy_policy" {
   name = "AWSCodeDeployFullAccess"
}

data "aws_iam_policy" "aws_s3_policy" {
   name = "AmazonS3FullAccess"
}

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

resource "aws_iam_user" "jenkins_user" {
   name = "jenkins_user"
}

resource "aws_iam_access_key" "jenkins_user_key" {
   user = aws_iam_user.jenkins_user.name
}

resource "aws_iam_user_policy_attachment" "jenkins_user_attach_cd" {
   user = aws_iam_user.jenkins_user.name
   policy_arn = data.aws_iam_policy.aws_code_deploy_policy.arn
}

resource "aws_iam_user_policy_attachment" "jenkins_user_attach_s3" {
   user = aws_iam_user.jenkins_user.name
   policy_arn = data.aws_iam_policy.aws_s3_policy.arn
}

resource "aws_security_group" "jenkins_server_sg" {
   name = "jenkins_server_sg"
   description = "Security group for jenkins server"
   vpc_id = var.vpc_id

   ingress {
      description = "Allow all traffic through port 8080"
      from_port = "8080"
      to_port = "8080"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
      description = "Allow SSH from my computer"
      from_port = "22"
      to_port = "22"
      protocol = "tcp"
      cidr_blocks = ["${var.my_ip}/32"]
   }

   egress {
      description = "Allow all outbound traffic"
      from_port = "0"
      to_port = "0"
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
      Name = "jenkins_server_sg"
   }
}

resource "aws_security_group" "jenkins_worker_server_sg" {
   name = "jenkins_worker_server_sg"
   description = "Security group for jenkins worker server"
   vpc_id = var.vpc_id

   ingress {
      description = "Allow SSH from my computer"
      from_port = "22"
      to_port = "22"
      protocol = "tcp"
      security_groups = [ aws_security_group.jenkins_server_sg.id ]
   }

   egress {
      description = "Allow all outbound traffic"
      from_port = "0"
      to_port = "0"
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
      Name = "jenkins_worker_server_sg"
   }
}


resource "aws_instance" "jenkins_server" {

  ami = data.aws_ami.ubuntu.id
  
  subnet_id =  var.subnet_id
  
  instance_type = "t2.micro"
  
  vpc_security_group_ids = [aws_security_group.jenkins_server_sg.id]

  associate_public_ip_address = true
  
  key_name = "devops"
  
  user_data = <<-EOF
   #!/bin/bash

   USER_HOME="/home/ubuntu"
   VOLUME_NAME="jenkins-volume"

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

   sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
   wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
   gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint
   echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list
   sudo apt update
   sudo apt-get install terraform

   cd $USER_HOME

   apt install unzip

   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install

   export AWS_ACCESS_KEY_ID=${aws_iam_access_key.jenkins_user_key.id}
   export AWS_SECRET_ACCESS_KEY=${aws_iam_access_key.jenkins_user_key.secret}
   export AWS_CONFIG_FILE=$USER_HOME/.aws/config
   export AWS_SHARED_CREDENTIALS_FILE=$USER_HOME/.aws/credentials
   aws configure set default.region us-east-1
   aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile jenkins
   aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile jenkins

   sudo chown -R ubuntu:ubuntu $USER_HOME/.aws/

   aws s3 cp s3://${var.bucket_name}/$VOLUME_NAME.tar.gz $USER_HOME/$VOLUME_NAME.tar.gz --profile jenkins
   tar -xf $USER_HOME/$VOLUME_NAME.tar.gz -C $USER_HOME/
   sudo chown -R ubuntu:ubuntu $USER_HOME/$VOLUME_NAME

   docker run -d \
      -p 8080:8080 \
      -v $USER_HOME/$VOLUME_NAME/:/var/jenkins_home  \
      -v /bin/terraform:/bin/terraform \
      -v $USER_HOME/.aws/:/var/jenkins_home/.aws \
      jenkins/jenkins:lts-jdk11
  EOF
   
  tags = {
    Name = "jenkins_server"
  }
}

resource "aws_instance" "jenkins_worker_server" {
  ami = data.aws_ami.ubuntu.id
  
  subnet_id =  var.subnet_id
  
  instance_type = "t2.micro"
  
  vpc_security_group_ids = [aws_security_group.jenkins_worker_server_sg.id]

  associate_public_ip_address = true
  
  key_name = "devops"

  user_data = <<-EOF
   #!/bin/bash

   USER_HOME="/home/ubuntu"
   VOLUME_NAME="jenkins-volume"

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

   cd $USER_HOME

   apt install unzip

   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install

   export AWS_ACCESS_KEY_ID=${aws_iam_access_key.jenkins_user_key.id}
   export AWS_SECRET_ACCESS_KEY=${aws_iam_access_key.jenkins_user_key.secret}
   export AWS_CONFIG_FILE=$USER_HOME/.aws/config
   export AWS_SHARED_CREDENTIALS_FILE=$USER_HOME/.aws/credentials
   aws configure set default.region us-east-1
   aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile jenkins
   aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile jenkins

   sudo chown -R ubuntu:ubuntu $USER_HOME/.aws/

   sudo apt update -y
   sudo apt install openjdk-11-jre -y
  EOF

  tags = {
   Name = "jenkins_worker_server"
  }
}

