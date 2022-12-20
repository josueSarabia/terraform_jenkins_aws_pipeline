resource "aws_ecr_repository" "app_frontend_repo" {
  name                 = var.repository_name_frontend
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository" "app_backend_repo" {
  name                 = var.repository_name_backend
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}