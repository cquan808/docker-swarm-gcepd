#!/bin/bash
sudo apt-get update
sudo apt-get install -y apt-transport-https software-properties-common ca-certificates curl wget
wget https://download.docker.com/linux/ubuntu/gpg
sudo apt-key add gpg
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu artful stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get -y install docker-ce=18.06.1~ce~3-0~ubuntu
# docker metrics setup
echo '{ "metrics-addr" : "0.0.0.0:9323", "experimental" : true }' >> /etc/docker/daemon.json
sudo service docker restart
curl localhost:9323/metrics
# install rexray-gcepd
sudo docker plugin install --grant-all-permissions rexray/gcepd GCEPD_TAG=rexray
sudo docker volume ls
# Increase Virtual Memory for Elasticsearch
sudo sysctl -w vm.max_map_count=262144
sudo echo 'vm.max_map_count=262144' >> sudo /etc/sysctl.conf
exit
