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
## --port 8888:80 : match le port 8888 de l'host avec le port 80 (ingress) du cluster pour rendre l'app accessible via l'ingress
## (peut aussi etre fait avec un loadbalancer sur le service -port <porthost>:<portservice>@loadbalancer ajouter type: LoadBalancer au service)
k3d cluster create argocd --api-port 127.0.0.1:6445 --port '8888:80@loadbalancer'


echo "==> Creating namespaces"
sudo kubectl create namespace argocd
sudo kubectl create namespace dev

sleep 40

echo "===> Deploy will's app "
## Installe argocd dans le cluster
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.3.0-rc5/manifests/ha/install.yaml

sudo kubectl apply -n argocd -f /IOT/confs/argocd.yaml
sudo kubectl apply -n dev -f /IOT/confs/ingress.yaml
while [[ $(kubectl get pods -n dev -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; \
    do echo "[DEV] Waiting for pods to be ready..." && sleep 10;
done

echo -en "\033[36m      PASSWORD=="; sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
echo -en "\033[0m"

echo "##Forwarding port to access service from outside : connect with 192.168.56.110:8080"
## Portforward le service argocd server present sur le port 443 du cluster vers le port 8080 de l'hote
## "--address 0.0.0.0" : port forward accessible de n'importe quelle ip pas juste localhost (donc du browser a l'exterieur de la vm avec <adresseVM>:8080)
sudo kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443 

