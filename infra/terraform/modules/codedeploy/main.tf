
resource "aws_codedeploy_app" "webapp" {
  name = var.application_name
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "webapp_deployment_group" {
  app_name              = aws_codedeploy_app.webapp.name
  deployment_group_name = "${var.application_name}_deployment_group"
  service_role_arn      = var.codedeploy_role_arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = var.web_server_name_tag
    }
  }
}

resource "aws_codedeploy_app" "webapp_staging" {
  name = "${var.application_name}_staging"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "webapp_staging_deployment_group" {
  app_name              = aws_codedeploy_app.webapp_staging.name
  deployment_group_name = "${var.application_name}_deployment_group_staging"
  service_role_arn      = var.codedeploy_role_arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = var.web_server_staging_name_tag
    }
  }
}
