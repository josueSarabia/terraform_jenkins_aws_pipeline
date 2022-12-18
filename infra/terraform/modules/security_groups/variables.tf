variable "vpc_id" {
  type = string
}

variable "allowed_ports" {
  type        = list(any)
  default     = ["80", "443"]
}

variable "my_ip" {
  type = string
}

output "prometheus_sg_id" {
  type = string
}