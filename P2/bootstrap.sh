#!/bin/bash

echo "=== Installing k3s"
echo "Setup the k3s node"

MYSECRET=iambatman
export INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --node-ip=192.168.56.110"
curl -fL https://get.k3s.io  | sed "s/sourcex/source/g" | K3S_TOKEN=${MYSECRET} \
    sh -s - 
while [ ! -e /var/lib/rancher/k3s/server/token ]
do
    sleep 1
done
sleep 15

echo "Deploy pods, services and ingress "
kubectl apply -f /IOT/pods/app1-deployment.yaml
kubectl apply -f /IOT/pods/app2-deployment.yaml
kubectl apply -f /IOT/pods/app3-deployment.yaml
kubectl apply -f /IOT/pods/ingress.yaml

echo "->Installation finished!"