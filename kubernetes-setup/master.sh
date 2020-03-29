#!/usr/bin/env bash

# Kubeadm init
#--experimental-upload-certs
echo "[TASK 1] Kubeadm init"
sudo kubeadm init --control-plane-endpoint "192.168.50.100:6443" --apiserver-advertise-address="192.168.50.10" --apiserver-cert-extra-sans="192.168.50.10"  --node-name k8s-master-1 --pod-network-cidr=192.168.0.0/24 --upload-certs

# Config Kube Conf
echo "[TASK 2] Config Kube Conf"
sudo mkdir -p /home/vagrant/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config
export KUBECONFIG=/home/vagrant/.kube/config
# Create CNI
echo "[TASK 3] Create CNI"

kubectl apply -f https://docs.projectcalico.org/v3.13/manifests/calico.yaml
#su - vagrant -c "kubectl create -f https://docs.projectcalico.org/v3.11/manifests/calico.yaml"

#Token Create
echo "[TASK 4] Token Create"
kubeadm token create --print-join-command > /home/vagrant/joincluster.sh

echo "Get Certificate Key"
sudo kubeadm init phase upload-certs --upload-certs > /home/vagrant/certificate_key
sudo sed -i -e '$!d' /home/vagrant/certificate_key


echo "---------------------FINISH MASTER-------------------------------"
#--apiserver-advertise-address="192.168.50.11"  --node-name k8s-master-2
