output "ec2_instance_profile" {
   description = "The IAM instance profile for the web server"
   value = aws_iam_instance_profile.ec2_code_deploy_instance_profile.id
}

output "codedeploy_iam_role_arn" {
   description = "The IAM role for the code deploy deployment group"
   value = aws_iam_role.ec2_code_deploy_instance_role.arn
}

output "codedeploy_role_arn" {
  value = aws_iam_role.aws_codedeploy_role.arn
}