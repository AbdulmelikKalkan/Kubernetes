#!/usr/bin/env bash

echo "[TASK 1] Install SSHPASS"
sudo yum install -q -y sshpass

echo "[TASK 2] Get Token File"
sudo sshpass -p "vagrant" scp -o StrictHostKeyChecking=no k8s-master-1:/home/vagrant/joincluster.sh /home/vagrant/joincluster.sh
sudo sshpass -p "vagrant" scp -o StrictHostKeyChecking=no k8s-master-1:/home/vagrant/certificate_key /home/vagrant/certificate_key

INTERNAL_IP=$(ip addr show eth1 | grep "inet " | awk '{print $2}' | cut -d / -f 1)
sed -i -e "s/$/  --apiserver-advertise-address='$INTERNAL_IP'  --node-name $HOSTNAME/" /home/vagrant/joincluster.sh
key=`cat /home/vagrant/certificate_key`
sed -i -e "s/$/  --control-plane --certificate-key $key/" /home/vagrant/joincluster.sh


echo "[TASK 3] Join Kubernetes"
sudo sh /home/vagrant/joincluster.sh

# Config Kube Conf
echo "[TASK 2] Config Kube Conf"
sudo mkdir -p /home/vagrant/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config
echo "---------------------FINISH CLUSTER MASTER -------------------------------"
