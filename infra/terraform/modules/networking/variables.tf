variable "cidr_block" {
    type = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
}

variable "environment" {
    type = string
  default = "dev"
}