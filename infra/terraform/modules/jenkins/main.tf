# Grab the AWS managed policy called AWSCodeDeployFullAccess
data "aws_iam_policy" "aws_code_deploy_policy" {
   name = "AWSCodeDeployFullAccess"
}

# Grab the AWS managed policy called AmazonS3FullAccess
data "aws_iam_policy" "aws_s3_policy" {
   name = "AmazonS3FullAccess"
}

# This data store is holding the most recent ubuntu 20.04 image
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

# Create an IAM user named jenkins_user
resource "aws_iam_user" "jenkins_user" {
   name = "jenkins_user"
}

# Create an IAM access key and access it to the jenkins_user user
resource "aws_iam_access_key" "jenkins_user_key" {
   user = aws_iam_user.jenkins_user.name
}

# Attach the CodeDeploy policy to the jenkins_user user
resource "aws_iam_user_policy_attachment" "jenkins_user_attach_cd" {
   user = aws_iam_user.jenkins_user.name
   policy_arn = data.aws_iam_policy.aws_code_deploy_policy.arn
}

# Attach the S3 policy to the jenkins_user user
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


# Creating an EC2 instance called jenkins_server
resource "aws_instance" "jenkins_server" {
  # Setting the AMI to the ID of the Ubuntu 20.04 AMI from the data store
  ami = data.aws_ami.ubuntu.id
  
  # Setting the subnet to the public subnet we created
  subnet_id =  var.subnet_id
  
  # Setting the instance type to t2.micro
  instance_type = "t2.micro"
  
  # Setting the security group to the security group we created
  vpc_security_group_ids = [aws_security_group.jenkins_server_sg.id]

  associate_public_ip_address = true
  
  # Setting the key pair name to the key pair we created
  key_name = "devops"
  
  # Setting the user data to the bash file called install_jenkins.sh
  user_data = <<-EOF
    #!/bin/bash
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
    sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    sudo apt update && sudo apt upgrade -y
    sudo apt install jenkins -y
    sudo systemctl start jenkins

  EOF

  # Setting the Name tag to jenkins_server
  tags = {
    Name = "jenkins_server"
  }
}

