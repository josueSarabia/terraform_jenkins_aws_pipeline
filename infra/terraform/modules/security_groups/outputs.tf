output "ec2_sg_public_subnet_id" {
    value = aws_security_group.ec2_sg_public_subnet.id
}

output "app_lb_sg_id" {
    value = aws_security_group.app_lb_sg.id
}