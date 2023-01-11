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
    sleep 10
    sudo cat /var/lib/rancher/k3s/server/node-token > /IOT/node-token
fi

if [ $(hostname) = "ldes-couSW" ]; then
    echo "Joining master - agent nodes "
    curl -sfL http://get.k3s.io | sed "s/sourcex/source/g" | INSTALL_K3S_EXEC="agent --server https://$IP_MASTER:6443 --node-ip=$IP_AGENT" K3S_TOKEN=$(cat /IOT/node-token) sh - # -s - --docker
fi


echo "->Installation finished!"

if [ ! -f ~/.first_boot ]; then
	touch ~/.first_boot
	echo "->Shutting down to finish install"
	sudo reboot
fi