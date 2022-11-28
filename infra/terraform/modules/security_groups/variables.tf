variable "vpc_id" {
  type = string
}

variable "allowed_ports" {
  type        = list(any)
  default     = ["80", "443"]
}

variable "environment" {
  type = string
  default = "dev"
}