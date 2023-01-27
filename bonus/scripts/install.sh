sudo apk update
apk add --update docker openrc
service docker start

echo "### Installing k3d"
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

echo "### Installing kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

echo "### Download argocd CLI"
sudo curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
sudo rm argocd-linux-amd64

echo "### Installing git"
sudo apk add git

echo "### Install helm "
bash /IOT/scripts/get_helm.sh

echo "->Create k3d cluster"
k3d cluster create argocd --port '8888:80@loadbalancer'

echo "Install gitlab "
kubectl create namespace gitlab
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install -n gitlab gitlab gitlab/gitlab

#-f https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/examples/values-minikube-minimum.yaml

# echo "==> Creating namespaces
# sudo kubectl create namespace argocd
# sudo kubectl create namespace dev

# sleep 40

# echo "===> Deploy will's app "
# sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.3.0-rc5/manifests/ha/install.yaml
# sudo kubectl apply -n argocd -f /IOT/confs/argocd.yaml
# sudo kubectl apply -n dev -f /IOT/confs/ingress.yaml
# while [[ $(kubectl get pods -n dev -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; \
#     do echo "[DEV] Waiting for pods to be ready..." && sleep 10;
# done


# echo "##Forwarding port to access service from outside : connect with 192.168.56.110:8080"
# export ARGOCD_OPTS='--port-forward-namespace argocd'

# echo -en "\033[36m      PASSWORD=="; sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
# echo -en "\033[0m"
# sudo kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443 


# echo "### Install GitLab"
# echo "http://dl-cdn.alpinelinux.org/alpine/v3.12/main" >> /etc/apk/repositories
# apk update
# apk add gitlab-ce
# gitlab-ctl reconfigure

