#!/bin/bash
docker stop $(docker ps -a -q) || true;
docker rm $(docker ps -a -q)  || true;
docker rmi -f $(docker images -aq) || true;