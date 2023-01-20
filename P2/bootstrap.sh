#!/bin/bash

echo "=== Installing k3s"
echo "=== Setting up k3s' node"


export INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --node-ip=192.168.56.110"
curl -fL https://get.k3s.io  | sed "s/sourcex/source/g" | sh -s - #| K3S_TOKEN=${MYSECRET} \

sleep 15

echo "=== Deploying pods, services and ingress"
kubectl apply -f /IOT/pods/app1-deployment.yaml
kubectl apply -f /IOT/pods/app2-deployment.yaml
kubectl apply -f /IOT/pods/app3-deployment.yaml
kubectl apply -f /IOT/pods/ingress.yaml

echo "->Installation finished!"