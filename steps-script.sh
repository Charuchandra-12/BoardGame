#!/bin/bash

# Kubernets kubedm setup (https://www.youtube.com/watch?v=o6bxo0Oeg6o)
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo service docker start

sudo chmod 666 /var/run/docker.sock

# --------------------------------------------------------------

# https://github.com/Mirantis/cri-dockerd/releases (wget deb package from url and then   sudo dpkg -i deb-package ). 

wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.12/cri-dockerd_0.3.12.3-0.ubuntu-jammy_amd64.deb

sudo dpkg -i cri-dockerd_0.3.12.3-0.ubuntu-jammy_amd64.deb


# --------------------------------------------------------------


sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl


# --------------------------------------------------------------


# CNI 
# https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart

# https://docs.tigera.io/calico/latest/getting-started/kubernetes/self-managed-onprem/onpremises

# sudo kubeadm init --pod-network-cidr=192.168.0.0/16 —> this give error for using  unix:///var/run/cri-dockerd.sock so run the below command —cri-socker got with —help command
 
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock
# follow the interactive steps then the below command

curl https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/calico.yaml -O

kubectl apply -f calico.yaml

# while adding the worker node it also requires --cri-socket=unix:///var/run/cri-dockerd.sock with the generated token

#-----------------------------------------------
# on runner 
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
sudo apt install maven -y

sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy
