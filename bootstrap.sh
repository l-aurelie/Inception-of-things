#!/bin/bash

echo "coucou ici le script"

# abort this script on errors.
# set -eux
export DEBIAN_FRONTEND=noninteractive

echo "install the desktop."
apt-get update

apt-get install -y --no-install-recommends \
    xorg \
    xserver-xorg-video-qxl \
    xserver-xorg-video-fbdev \
    xserver-xorg-video-vmware \
    xfce4 \
    xfce4-terminal \
    lightdm \
    lightdm-gtk-greeter \
    xfce4-whiskermenu-plugin \
    xfce4-taskmanager \
    menulibre 

echo "install docker"
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"
sudo apt update 
apt-cache search docker-ce
sudo apt install -y docker-ce


echo "add your user to docker group"
sudo groupadd docker
sudo usermod -aG docker vagrant
# newgrp docker

echo "installing k3s"
echo "setup the master k3s node" 
curl -sfL https://get.k3s.io | sh -s - --docker

echo "allow port on firewall"
sudo ufw allow 6443/tcp
sudo ufw allow 443/tcp

# echo "install k3s on workers node and connect them to master"
# curl -sfL http://get.k3s.io | K3S_URL=https://<master_IP>:6443 K3S_TOKEN=<join_token> sh -s - --docker


echo "don't forget to install  ks3"

echo "->Installation finished! login with vagrant:vagrant"

if [ ! -f ~/.first_boot ]; then
	touch ~/.first_boot
	echo "->Shutting down to finish install, re-run vagrant up"
	reboot
fi