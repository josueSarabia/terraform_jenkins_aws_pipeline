#!/bin/bash
docker compose -f ./docker-compose/app/FEATURE/docker-compose.yml down --rmi all || true;
#docker stop $(docker ps -a -q) || true;
#docker rm $(docker ps -a -q | grep)  || true;
#docker rmi -f $(docker images -aq) || true;