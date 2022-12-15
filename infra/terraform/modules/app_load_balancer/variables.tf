variable "application_name" {
  type        = string
}

variable "app_port" {
  default = 80
}

variable "subnets" {
  type = list(any)
}

variable "load_balancer_sg" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "web_servers_info" {
  type = list(any)
}