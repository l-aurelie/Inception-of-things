#!/bin/bash
IP_MASTER=192.168.56.110

echo "=== Installing docker"
sudo apk add docker
sudo addgroup vagrant docker
sudo rc-update add docker boot

echo "=== Installing k3s"
#get current IP
# current_ip=$(/sbin/ip -o -4 addr list enp0s8 | awk '{print $4}' | cut -d/ -f1)
echo "Setup the master k3s node"

MYSECRET=iambatman
curl -fL https://get.k3s.io  | K3S_TOKEN=${MYSECRET} \
    sh -s - --disable traefik server --write-kubeconfig-mode
#sudo chmod 644 /etc/rancher/k3s/k3s.yaml
#sed "s/sourcex/source/g"  /lib/rc/sh/gendepends.sh
echo "->Installation finished!"

if [ ! -f ~/.first_boot ]; then
	touch ~/.first_boot
	echo "-> Rebooting to finish install"
	sudo reboot
fi