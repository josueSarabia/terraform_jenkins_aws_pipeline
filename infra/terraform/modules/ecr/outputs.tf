output "ecr_frontend_repo_url" {
    value = aws_ecr_repository.app_frontend_repo.repository_url
}

output "ecr_backend_repo_url" {
    value = aws_ecr_repository.app_backend_repo.repository_url
}