IP_SERVER="192.168.56.110"

sudo apk update
apk add --update docker openrc
service docker start

echo "###Installing k3d"
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

echo "###Installing kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

echo "##Download argocd CLI"
sudo curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
sudo rm argocd-linux-amd64

echo "->Create k3d cluster"
sudo k3d cluster create argocd

sleep 20

echo "==> Creating namespaces"
sudo kubectl create namespace argocd
sudo kubectl create namespace dev


echo "===> Deploy will's app "
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.3.0-rc5/manifests/ha/install.yaml
sudo kubectl apply -n argocd -f /IOT/argocd.yaml
sudo kubectl apply -n dev -f /IOT/ingress.yaml

# while [[ $(kubectl -n dev get pods -l app=app-wil42-argocd -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]];
#     do echo "waiting for pod" && sleep 1;
# done
# while [[ $(kubectl -n argocd get pods -l app=app-wil42-argocd -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]];
#     do echo "waiting for pod" && sleep 1;
# done

sleep 80

echo "##Forwarding port to access service from outside : connect with 192.168.56.110:8080"
export ARGOCD_OPTS='--port-forward-namespace argocd'

echo -en "\033[36m      PASSWORD=="; sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
echo -en "\033[0m"
sudo kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443 

