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
    # Dl le script d'installation de k3s, l'execute avec les variables (la varaible write-kubeconfig-mode permet de donner les droit pour executer kubectl)
    curl -sfL https://get.k3s.io | sed "s/sourcex/source/g" | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --node-ip $IP_MASTER --bind-address=$IP_MASTER --advertise-address=$IP_MASTER" sh -
    # Recuperation du token necessite par les workers nodes
    while [ ! -f /var/lib/rancher/k3s/server/token ]; do sleep 1; done
    sudo cat /var/lib/rancher/k3s/server/node-token > /IOT/node-token
    # Recuperation du .kube/config necessite par les workers nodes
    mkdir /IOT/.kube
    sudo cat /etc/rancher/k3s/k3s.yaml > /IOT/.kube/config
fi

if [ $(hostname) = "ldes-couSW" ]; then
    echo "Joining master - agent nodes "
    mkdir .kube
    cp /IOT/.kube/config /home/vagrant/.kube/config
    sed "s/192.168.56.110:6443/192.168.56.111:6443/g"
    # Execute de le script d'installation de k3s en mode agent en precisant ip:port du server et son token
    curl -sfL http://get.k3s.io | sed "s/sourcex/source/g" | INSTALL_K3S_EXEC="agent --server https://$IP_MASTER:6443 --node-ip=$IP_AGENT" K3S_TOKEN=$(cat /IOT/node-token) sh -
fi


echo "->Installation finished!"