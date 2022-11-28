# subnet of jenkins server
output "public_subnet" {
  value = aws_subnet.public[0]
}

output "vpc_id" {
  value =aws_vpc.main.id
}

output "public_subnets_info" {
  value = aws_subnet.public[*]
}