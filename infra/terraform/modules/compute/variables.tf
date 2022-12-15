variable "region" {
  type    = string
  default = "us-east-1"
}

variable "web_instance_profile" {
  description = "The IAM instance profile of the web server"
}

variable "public_subnets" {
  type    = list(any)
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "web_security_groups" {
  type = list(string)
}

variable "web_staging_security_groups" {
  type = list(string)
}