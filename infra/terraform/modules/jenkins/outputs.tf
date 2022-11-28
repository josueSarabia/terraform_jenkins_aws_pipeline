output "jenkins_public_ip" {
  description = "The public IP address of the Jenkins server"
  value = aws_instance.jenkins_server.public_ip
}

output "jenkins_user_access_key" {
   description = "The access key of the Jenkins user"
   value = aws_iam_access_key.jenkins_user_key.id
}

output "jenkins_user_secret" {
   description = "The secret of the Jenkins user" 
   value = aws_iam_access_key.jenkins_user_key.secret
   sensitive = true
}