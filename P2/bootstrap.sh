#!/bin/bash
IP_MASTER=192.168.56.110

echo "=== Installing docker"
sudo apk add docker
sudo addgroup vagrant docker
sudo rc-update add docker boot

echo "=== Installing k3s"
echo "Setup the master k3s node"

MYSECRET=iambatman
export INSTALL_K3S_EXEC="--write-kubeconfig-mode=644"
curl -fL https://get.k3s.io  | sed "s/sourcex/source/g" | K3S_TOKEN=${MYSECRET} \
    sh -s - --docker #--disable traefik server 

echo "->Installation finished!"

if [ ! -f ~/.first_boot ]; then
	touch ~/.first_boot
	echo "-> Rebooting to finish install"
	sudo reboot
fi