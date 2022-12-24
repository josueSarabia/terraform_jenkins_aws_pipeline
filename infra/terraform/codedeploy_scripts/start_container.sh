#!/bin/bash
# docker run -p 80:8081 -d REPO_URL:COMMIT;
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ECR_REPO_URL
docker compose -f ./docker-compose/app/FEATURE/docker-compose.yml up -d