#!/bin/sh

docker rm -f $(docker ps -q) || true
docker container rm -f $(docker container ls -qa) || true
docker image rm $(docker image ls -qa) || true

minikube delete
brew uninstall --force docker-compose docker minikube hyperkit