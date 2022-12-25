#!/bin/bash
# docker run -p 80:8081 -d REPO_URL:COMMIT;
service=FEATURE

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ECR_REPO_URL
if [[ service = "backend" ]]; then
    docker network create frontend_default || true
fi
docker compose -f /home/ubuntu/docker-compose/app/$service/docker-compose.yml up -d