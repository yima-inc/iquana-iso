#!/bin/bash

set -e -x

# install-deb-packages ########################################################
TEMPDIR=`mktemp -d`

chmod +rx "$TEMPDIR"

tar -C "$TEMPDIR" -x -z -f /opt/firstboot/install-deb-packages.tgz
cd "$TEMPDIR"/install-deb-packages
sh install-deb-packages.sh
cd -

rm -rf "$TEMPDIR"
###############################################################################


# install-k3s-installer #######################################################
TEMPDIR=`mktemp -d`

tar -C "$TEMPDIR" -x -z -f /opt/firstboot/install-k3s-installer.tgz
cd "$TEMPDIR"/install-k3s-installer
sh ./install-k3s-installer.sh
cd -

rm -rf "$TEMPDIR"
###############################################################################


# install-cockpit-plugins #####################################################
TEMPDIR=`mktemp -d`

tar -C "$TEMPDIR" -x -z -f /opt/firstboot/install-cockpit-plugins.tgz
cd "$TEMPDIR"/install-cockpit-plugins
sh ./install-cockpit-plugins.sh
cd -

rm -rf "$TEMPDIR"
###############################################################################

# install-custom-images #######################################################
TEMPDIR=`mktemp -d`

tar -C "$TEMPDIR" -x -z -f /opt/firstboot/install-custom-images.tgz
cd "$TEMPDIR"/install-custom-images
sh ./install-custom-images.sh
cd -

rm -rf "$TEMPDIR"
###############################################################################


# override netplan configuration ##############################################
rm -f /etc/netplan/00-installer-config.yaml
cat >/etc/netplan/50-iquana.yaml <<EOF
network:
  version: 2
  renderer: NetworkManager
EOF
###############################################################################

# use network-manager instead of networkd #####################################
systemctl stop systemd-networkd.service
systemctl disable systemd-networkd.service
systemctl mask systemd-networkd.service
systemctl unmask NetworkManager
systemctl enable NetworkManager
systemctl start NetworkManager

nmcli connection add type ethernet con-name eth0-connection ifname eth0 ip4 192.168.11.127/24
nmcli connection add type ethernet con-name eth1-connection ifname eth1 ip4 192.168.20.127/24
###############################################################################

# enable ntp ##################################################################
timedatectl set-ntp true
###############################################################################


systemctl disable firstboot.service

shutdown -h now
