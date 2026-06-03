#!/bin/bash
docker rm -f $(docker ps -aq) 2> /dev/null || true
docker rmi -f $(docker images -aq) 2> /dev/null || true