variable "environment" {
  default = "dev"
}

variable "application_name" {
  type = string
}

variable "deployment_group_name" {
  type = string
}

variable "web_server_name_tag" {
  type = string
}

variable "codedeploy_role_arn" {
  type = string
}