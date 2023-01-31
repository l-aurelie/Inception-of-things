echo "->Installing Helm and k3d:"
apk add helm docker openrc
apk add git
service docker start
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
curl -L https://storage.googleapis.com/kubernetes-release/release/v1.25.0/bin/linux/amd64/kubectl > /tmp/kubectl
install /tmp/kubectl /usr/local/bin/kubectl

echo "->creating k3d cluster:"
k3d cluster create bonus --port 8080:80@loadbalancer

echo "->Copying k3d credentials to vagrant user"
mkdir -p /home/vagrant/.kube && cp /root/.kube/config /home/vagrant/.kube/config && chown vagrant /home/vagrant/.kube/config


echo "Install gitlab "
sudo kubectl create namespace gitlab
sudo helm repo add gitlab https://charts.gitlab.io/

sudo helm install -f /IOT/confs/gitlab-minimum.yaml -n gitlab gitlab gitlab/gitlab


echo " ==> Installing argocd "
sudo kubectl create namespace argocd
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.3.0-rc5/manifests/ha/install.yaml

echo " ==> Waiting for gitlab pods to be ready "
sudo kubectl wait --for=condition=available deployments --all -n gitlab --timeout=800s

##Forwarding port to access argocd service from outside : connect with 192.168.56.110:8080
echo "\033[36m      ARGOCD_PASSWORD:" ; sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
echo "				GITLAB_PASSWORD:" ; sudo kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -ojsonpath={.data.password} | base64 -d ; echo

echo "Forwarding port "
sudo kubectl port-forward --address 0.0.0.0 svc/gitlab-webservice-default -n gitlab 8585:8181 | sudo kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8282:443
sudo kubectl apply -n argocd -f /IOT/confs/argocd.yaml
# sudo kubectl apply -n dev -f /IOT/confs/deployment.yaml
