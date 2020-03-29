#!/usr/bin/env bash

echo "[TASK 1] Install SSHPASS"
sudo yum install -q -y sshpass

echo "[TASK 2] Get Token File"
sudo sshpass -p "vagrant" scp -o StrictHostKeyChecking=no k8s-master-1:/home/vagrant/joincluster.sh /home/vagrant/joincluster.sh

echo "[TASK 3] Join Kubernetes"
sudo sh /home/vagrant/joincluster.sh

echo "---------------------FINISH NODE-------------------------------"
