#!/usr/bin/env bash

#sudo bash -c 'cat >> /etc/hosts <<EOF
#192.168.50.10  k8s-master-1
#192.168.50.11  k8s-master-2
#192.168.50.12  node-1
#192.168.50.13  node-2
#192.168.50.100  loadbalancer
#EOF'

#sudo bash -c 'cat >> /etc/sudoers <<EOF
#vagrant  ALL=(ALL:ALL) ALL
#EOF'

# Unistall Old Version
echo "[TASK 1] Unistall Old Docker Version"
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

# Set Up the Repository
echo "[TASK 2] Set Up the Repository"
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

echo "[TASK 3] add docker repo"
sudo yum-config-manager \
      --add-repo \
      https://download.docker.com/linux/centos/docker-ce.repo

# Install docker Packages
echo "[TASK 4] Install Docker"
sudo yum install -y docker-ce docker-ce-cli containerd.io

# Enable docker service
echo "[TASK 5] Enable Docker Service"
sudo systemctl enable docker

# Start docker service
echo "[TASK 6] Start Docker Service"
sudo systemctl start docker

#Run Nginx Images
echo "[TASK 7] Run Nginx Images"
sudo docker run --name proxy \
    -v /etc/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
    -p 6443:6443 \
    -d nginx
