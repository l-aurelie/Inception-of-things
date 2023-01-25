sudo apt-get update
sudo apt-get install -y vim
sudo apt-get remove docker docker-engine docker.io containerd runc


echo "###Installing Docker"
echo"->Setup docker repo"
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "->Installing docker engine"
sudo chmod a+r /etc/apt/keyrings/docker.gpg
sudo apt-get update


sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo groupadd docker
sudo usermod -aG docker ${USER}
sudo su -l ${USER}

echo "###Docker installed successfully"

echo "###Installing k3d"
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

echo "###Installing kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

echo "->Create k3d cluster"
k3d cluster create argocd --api-port 127.0.0.1:6445 --port '8888:80@loadbalancer'

echo "###Installing argcd"
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.3.0-rc5/manifests/ha/install.yaml

echo "##Download argocd CLI"
sudo curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
sudo rm argocd-linux-amd64

echo "##Log in to argocd server"
export ARGOCD_OPTS='--port-forward-namespace argocd'
argocd login 172.18.0.3 --insecure --username admin --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)
argocd account update-password

# kubectl config set-context --current --namespace=argocd

# echo "##To connect to the service without exposing it / connect with localhost:8080"
# #kubectl port-forward svc/argocd-server -n argocd 8080:443

echo "===> Deploy will's app on dev namespace"
kubectl create namespace dev
kubectl apply -n dev -f /media/sf_P3/deployment.yaml
kubectl apply -n dev -f /media/sf_P3/ingress.yaml


