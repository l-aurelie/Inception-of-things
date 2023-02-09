echo "### Installing dependencies"
apk add git htop
apk add helm docker openrc
service docker start
echo "### Installing helm and k3d"
apk add helm
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
curl -L https://storage.googleapis.com/kubernetes-release/release/v1.25.0/bin/linux/amd64/kubectl > /tmp/kubectl
install /tmp/kubectl /usr/local/bin/kubectl

echo "==> Creating k3d cluster"
## Rend l'app accessible a l'aide du loadBalancer sur le service <porthost>:<portService>, ajouter "type: LoadBalancer" au service
k3d cluster create bonus --port 8888:8888@loadbalancer
echo "-> Adding credentials to user" # pour avoir les droits kubectl
mkdir -p /home/vagrant/.kube && cp /root/.kube/config /home/vagrant/.kube/config && chown vagrant /home/vagrant/.kube/config

echo "### Installing gitlab "
sudo kubectl create namespace gitlab
sudo helm repo add gitlab https://charts.gitlab.io/
## Possible de passer les helm charts en parametre ou comme ici de les mettre dans une fichier yaml
sudo helm install -f /IOT/confs/gitlab-minimum.yaml -n gitlab gitlab gitlab/gitlab

echo "### Installing argocd "
sudo kubectl create namespace argocd
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.3.0-rc5/manifests/ha/install.yaml

echo " ==> Waiting for gitlab pods to be ready "
sudo kubectl wait --for=condition=available deployments --all -n gitlab --timeout=800s

echo " ==> Init git repository"
cd /IOT/confs
git init
git add deployment.yaml
git commit -m "app conf"
git remote add origin "http://192.168.56.110:8585/root/app-wil42.git"


echo "\033[36m      ARGOCD_PASSWORD:" ; sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
echo "				GITLAB_PASSWORD:" ; sudo kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -ojsonpath={.data.password} | base64 -d ; echo

echo "==> Forwarding port "
## Port forward les service gitlab et argocd (& en background)
    sudo kubectl port-forward --address 0.0.0.0 svc/gitlab-webservice-default -n gitlab 8585:8181 | sudo kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8282:443 &

password=$(sudo kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -ojsonpath={.data.password} | base64 -d)

cd /IOT/confs
waiting_repo=1
echo $waiting_repo
while [ $waiting_repo != 0 ] ; do
    git push http://root:${password}@192.168.56.110:8585/root/app-wil42.git
    waiting_repo=$?
    echo $waiting_repo
    if [ $waiting_repo != 0 ] ; then
        echo "Please connect to gitlab at 192.168.56.110:8585 as root and create repo <app-wil42> in namespace <root>"
    else
        echo "==> Confs for deployment succesfully pushed on gitlab"
    fi
    sleep 7
done

sleep 50

echo "==> Apply argo cd conf"
sudo kubectl apply -n argocd -f /IOT/confs/argocd.yaml
#sudo kubectl apply -n gitlab -f /IOT/confs/ingress.yaml

echo "==> You can connect to gitlab 192.168.56.110:8585 as root on your browser"
echo "==> You can connect to argocd 192.168.56.110:8282 as admin on your browser"