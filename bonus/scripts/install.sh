echo "### Installing dependencies"
apk update
apk add --update docker openrc git
service docker start

echo "### Installing k3d"
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

echo "### Installing kubectl"
curl -L https://storage.googleapis.com/kubernetes-release/release/v1.25.0/bin/linux/amd64/kubectl > /tmp/kubectl
install /tmp/kubectl /usr/local/bin/kubectl

echo "### Install helm "
bash /IOT/scripts/get_helm.sh

echo "==> Create k3d cluster"
k3d cluster create argocd --port '8888:80@loadbalancer'
mkdir -p /home/vagrant/.kube && cp /root/.kube/config /home/vagrant/.kube/config && chown vagrant /home/vagrant/.kube/config

echo "Download argocd CLI"
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

echo "### Installing argocd "
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.3.0-rc5/manifests/ha/install.yaml

echo "### Install gitlab "
kubectl create namespace gitlab
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install -f /IOT/confs/gitlab-minimum.yaml -n gitlab gitlab gitlab/gitlab

echo " ==> Waiting for gitlab pods to be ready "
kubectl wait --for=condition=available deployments --all -n gitlab --timeout=800s


## sleep 40

## echo "===> Deploy will's app "
## sudo kubectl apply -n argocd -f /IOT/confs/argocd.yaml
## sudo kubectl apply -n dev -f /IOT/confs/ingress.yaml

echo "\033[36m      ARGOCD_PASSWORD:" ; sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
echo "				GITLAB_PASSWORD:" ; sudo kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -ojsonpath={.data.password} | base64 -d ; echo

echo "Forwarding port "
sudo kubectl port-forward --address 0.0.0.0 svc/gitlab-webservice-default -n gitlab 8585:8181 | sudo kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8282:443
sudo kubectl apply -n argocd -f /IOT/confs/argocd.yaml
## sudo kubectl apply -n dev -f /IOT/confs/deployment.yaml