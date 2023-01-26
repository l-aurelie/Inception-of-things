

echo "->Create k3d cluster"
k3d cluster create argocd --api-port 127.0.0.1:6445 --port '8888:80@loadbalancer'

echo "==> Creating namespace argocd"
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.3.0-rc5/manifests/ha/install.yaml

sleep 20

echo "===> Deploy will's app on dev namespace"
kubectl create namespace dev
kubectl apply -n argocd -f /media/sf_P3/argocd.yaml
kubectl apply -n dev -f /media/sf_P3/ingress.yaml

echo "##To connect to the service without exposing it / connect with localhost:8080"
export ARGOCD_OPTS='--port-forward-namespace argocd'
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
# argocd login localhost:8080 --insecure --username admin --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)
# argocd account update-password