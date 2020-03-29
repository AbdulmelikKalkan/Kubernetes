#!/usr/bin/env bash

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

sudo bash -c 'cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF'
sudo systemctl daemon-reload
systemctl restart docker

# Add vagrant user to docker group
echo "[TASK 7] Add vagrant user to docker group"
sudo usermod -a -G docker vagrant

#Disable SELinux
echo "[TASK 7] Disable SELinux"
sudo setenforce 0
sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# Swapoff
echo "[TASK 8] wapoff"
sudo sed -i '/swap/d' /etc/fstab
sudo swapoff -a

# Set Up Kubernetes Repo
echo "[TASK 9] Set Up Kubernetes Repo"
sudo bash -c 'cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF'
# Install Kubernetes
echo "[TASK 10] Install Kubernetes"
sudo yum install -y kubectl kubelet kubeadm

# Enale kubelet
echo "[TASK 11] enable kubelet"
sudo systemctl enable kubelet
#Start kubelet
echo "[TASK 12] Start kubelet"
sudo systemctl start kubelet
#Reload Deamon
echo "[TASK 13] Reload Deamon"
sudo systemctl daemon-reload

cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

# Config iptables
echo "[TASK 14] Config iptables"
sudo echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
