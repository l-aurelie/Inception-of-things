#!/bin/bash
HOSTNAME=$(hostname)
IP_MASTER=192.168.56.110
IP_AGENT=192.168.56.111

echo "=== Installing docker"
sudo apk add docker
sudo addgroup vagrant docker
sudo rc-update add docker boot

echo "=== Installing k3s"
if [ $(hostname) = "ldes-couS" ]; then
    echo "Setup the master k3s node"
    curl -sfL https://get.k3s.io | sed "s/sourcex/source/g" | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --node-ip $IP_MASTER --bind-address=$IP_MASTER --advertise-address=$IP_MASTER" sh - # -s - --docker
    while [ ! -f /var/lib/rancher/k3s/server/token ]; do sleep 1; done
    sudo cat /var/lib/rancher/k3s/server/node-token > /IOT/node-token
    mkdir /IOT/.kube
    sudo cat /etc/rancher/k3s/k3s.yaml > /IOT/.kube/config
fi

if [ $(hostname) = "ldes-couSW" ]; then
    echo "Joining master - agent nodes "
    mkdir .kube
    cp /IOT/.kube/config /home/vagrant/.kube/config
    sed "s/192.168.56.110:6443/192.168.56.111:6443/g"

    curl -sfL http://get.k3s.io | sed "s/sourcex/source/g" | INSTALL_K3S_EXEC="agent --server https://$IP_MASTER:6443 --node-ip=$IP_AGENT" K3S_TOKEN=$(cat /IOT/node-token) sh - # -s - --docker
fi


echo "->Installation finished!"