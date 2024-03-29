#!/usr/bin/env bash

sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker


cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet

firewall-cmd --add-port 6443/tcp --permanent
firewall-cmd --reload

sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
sudo ln -s /opt/kubectx/kubens /usr/bin/kubens

OS=CentOS_9_Stream
VERSION=1.25
sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/devel:kubic:libcontainers:stable.repo
sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo
sudo yum install -y cri-o
sudo systemctl enable --now crio

sudo kubeadm init --apiserver-advertise-address=192.168.1.210 --pod-network-cidr 10.244.0.0/16 --cri-socket=unix:///var/run/crio/crio.sock
sudo mkdir -p $HOME/.kube
sudo sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=/etc/kubernetes/admin.conf

sudo kubectl taint nodes --all node-role.kubernetes.io/control-plane-
sudo kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

#Wait until cni0 up and runing
ret=1
until [ $ret -eq 0 ]
do
    echo "Waiting cni0 up and running..."
    ip address | grep -q cni0
    ret=$?
    sleep 1
done

#Wait until flannel.1 up and runing
ret=1
until [ $ret -eq 0 ]
do
    echo "Waiting flannel.1 up and running..."
    ip address | grep -q flannel.1
    ret=$?
    sleep 1
done


sudo ip link set cni0 down && sudo ip link set flannel.1 down 
sudo ip link delete cni0 && sudo ip link delete flannel.1
sudo systemctl restart containerd && sudo systemctl restart kubelet
sleep 10
sudo kubectl apply -f /data/dashboard.yml
sudo kubectl apply -f /data/dashboard-serviceaccount.yml
