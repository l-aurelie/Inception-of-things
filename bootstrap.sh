#!/bin/bash

echo "coucou ici le script"

#!/bin/bash
# abort this script on errors.
set -eux

# prevent apt-get et al from opening stdin.
# NB even with this, you'll still get some warnings that you can ignore:
#     dpkg-preconfigure: unable to re-open stdin: No such file or directory
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
    # firefox

# # install useful tools.
# apt-get install -y --no-install-recommends git-core meld
# apt-get install -y --no-install-recommends httpie
# apt-get install -y --no-install-recommends vim
echo "install guest additions"
apt-get install build-essential module-assistant
apt-get install -y --no-install-recommends virtualbox-guest-x11
m-a prepare

echo "don't forget to install  ks3"

apt-get remove -y --purge xscreensaver
apt-get autoremove -y --purge
echo "->Installation finished! login with vagrant:vagrant"

if [ ! -f ~/.first_shutdown ]; then
	touch ~/.first_shutdown
	echo "->Shutting down to finish install, re-run vagrant up"
	poweroff
fi

