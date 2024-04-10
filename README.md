# Steps to setup the infrastructure

**set up k8s cluster (https://www.youtube.com/watch?v=o6bxo0Oeg6o)**

## 1. Install Docker

**Add Docker's official GPG key:**

```
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

**Add the repository to Apt sources:**

```
echo \
 "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
 $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
 sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo service docker start

sudo chmod 666 /var/run/docker.sock
```

## 2. Install custom container runtime

**https://github.com/Mirantis/cri-dockerd/releases**

```
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.12/cri-dockerd_0.3.12.3-0.ubuntu-jammy_amd64.deb

sudo dpkg -i cri-dockerd_0.3.12.3-0.ubuntu-jammy_amd64.deb
```

## 3. Install kubelet kubeadm kubectl (3rd step in Master and Worker Node)

```
sudo apt-get update

sudo apt-get install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

## 4. Setup Master Node with Custom Networking solution (Only On Master Node and utilize the genereated token in worker node)

**CNI**

**https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart**

**https://docs.tigera.io/calico/latest/getting-started/kubernetes/self-managed-onprem/onpremises**

**sudo kubeadm init --pod-network-cidr=192.168.0.0/16 —> this give error for using unix:///var/run/cri-dockerd.sock so run the below command —cri-socket... got with —help command**

`sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock`

**follow the interactive steps then the below command**

`curl https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/calico.yaml -O`

'kubectl apply -f calico.yaml`

**after createing the cluster utilize the "sa_role_role_binding.yaml" file. And deployment-service.yaml file will get utilized in the pipeline.**

**while adding the worker node it also requires --cri-socket=unix:///var/run/cri-dockerd.sock with the generated token**

## 5. Create a custom runner for GitHub Actions (get the commands and from github itself and run the commands on the ec2 instace to make it runner) and on runner Install the below packages

## 5.1 Install the Docker from the step 1 on to the Runner then install the sonarqube server

`docker run -d --name sonar -p 9000:9000 sonarqube:lts-community`

## 5.2 Install maven

`sudo apt install maven -y`

## 5.3 Install trivy

```
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy
```

**untar command:- "tar -xvf tarfile" and run the corresponding executable script with ./ and & to run them in the background for the below packages except for the grafana.**

## 5.4 Install prometheus ("pgrep prometheus" to get the id and then kill the process, then start it again when adding and configuring the exporters) (edit the prometheus yaml file after installing the exporters)

`wget https://github.com/prometheus/prometheus/releases/download/v2.51.1/prometheus-2.51.1.linux-amd64.tar.gz`

## 5.5 Install blackbox_exporter

`wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.24.0/blackbox_exporter-0.24.0.linux-amd64.tar.gz`

## 5.6 Install node_exporter

`wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz`

## 5.7 Install Grafana (After installing the Grafana it generates the command to run the grafana, so utilze that command, After adding the data source (i.e prometheus), add the 2 dashboards for correspondig exporters to get the insights )

**https://grafana.com/grafana/download**

## screenshots from my implemented project for the above steps.

**Cluster and runner virtual machines**
![alt text](<project_pics/Screenshot 2024-04-09 at 10.04.49 AM.png>)

**Cluster created with custom CNI solution and app. deployed with cicd**
![alt text](<project_pics/Screenshot 2024-04-09 at 10.07.00 AM.png>)

**Custom config. for blackbox and node exporter**
![alt text](<project_pics/Screenshot 2024-04-09 at 10.08.24 AM.png>)

**Pipeline ran successfully and external ip is worker node's ip**
![alt text](<project_pics/Screenshot 2024-04-09 at 10.09.19 AM.png>)

**Sonar qube analysis**
![alt text](<project_pics/Screenshot 2024-04-09 at 10.10.08 AM.png>)

**Target endpoints in prometheus**
![alt text](<project_pics/Screenshot 2024-04-09 at 10.10.18 AM.png>)

**Application webpage**
![alt text](<project_pics/Screenshot 2024-04-09 at 10.10.29 AM.png>)

**Grafana dashboards**
![alt text](<project_pics/Screenshot 2024-04-09 at 10.10.36 AM.png>)

**Node exporter dashboard**
![alt text](<project_pics/Screenshot 2024-04-09 at 10.10.44 AM.png>)

**Blackbox exporter dashboard**
![alt text](<project_pics/Screenshot 2024-04-09 at 10.10.57 AM.png>)

**Reference :- https://www.youtube.com/watch?v=FTrTFOLbdm4**
