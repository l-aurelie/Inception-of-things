#!/bin/bash
HOSTNAME=$(hostname)
IP_MASTER=192.168.56.110
IP_AGENT=192.168.56.111

echo "coucou ici le script"

#apt-get update

#echo "install docker"
#sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"
#sudo apt update 
#apt-cache search docker-ce
#sudo apt install -y docker-ce


#echo "add your user to docker group"
#sudo groupadd docker
#sudo usermod -aG docker vagrant

echo "installing k3s"
echo "setup the master k3s node" 
if [ $(hostname) = "ldes-couS" ]; then
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --node-ip $IP_MASTER --bind-address=$IP_MASTER --advertise-address=$IP_MASTER" sh - # -s - --docker
    sudo cat /var/lib/rancher/k3s/server/node-token > /IOT/node-token
#    echo $TOKEN
fi

echo "joining master - agent nodes "
if [ $(hostname) = "ldes-couSW" ]; then
    curl -sfL http://get.k3s.io | INSTALL_K3S_EXEC="agent --server https://$IP_MASTER:6443 --node-ip=$IP_AGENT" K3S_TOKEN=$(cat /IOT/node-token) sh - # -s - --docker
fi


echo "->Installation finished! login with vagrant:vagrant"

if [ ! -f ~/.first_boot ]; then
	touch ~/.first_boot
	echo "->Shutting down to finish install"
	sudo reboot
fi