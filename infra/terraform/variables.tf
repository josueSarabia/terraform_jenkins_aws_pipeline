variable "region" {
  type    = string
  default = "us-east-1"
}

variable "profile" {
  type    = string
  default = "default"
}

variable "environment" {
  default = "dev"
}

variable "cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "application_name" {
  type        = string
  default     = "simple-web"
}

variable "my_ip" {
  default = "190.84.119.238"
}