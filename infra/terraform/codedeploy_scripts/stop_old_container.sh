#!/bin/bash
docker compose down --rmi all || true;
#docker stop $(docker ps -a -q) || true;
#docker rm $(docker ps -a -q | grep)  || true;
#docker rmi -f $(docker images -aq) || true;