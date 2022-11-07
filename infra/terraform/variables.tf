variable "region" {
  type    = string
  default = "us-east-1"
}

/* variable "profile" {
  type    = string
  default = "default"
} */

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "environment" {
  default = "dev"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "allowed_ports" {
  type        = list(any)
  default     = ["80", "443"]
}

variable "app_name" {
  type        = string
  default     = "SimpleWebPage"
}

variable "app_port" {
  default = 80
}