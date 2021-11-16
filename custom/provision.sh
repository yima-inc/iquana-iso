#!/bin/sh

set -e -x

# turn off swap
swapoff -a
rm /swap.img
sed -i -e 's|^/swap.*||g' /etc/fstab

# extend filesystem
lvresize -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv

# update grub
sed -i 's|GRUB_CMDLINE_LINUX=""|GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"|g' /etc/default/grub
update-grub

# no sudo password
echo 'iquana ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# update /etc/issue
echo "eth0: \\\4{eth0}" >> /etc/issue
echo "eth1: \\\4{eth1}" >> /etc/issue
echo >> /etc/issue

# clear /etc/apt/sources.list
echo >/etc/apt/sources.list

# disable systemd services ####################################################
rm -f \
    /etc/systemd/system/timers.target.wants/apt-daily.timer \
    /etc/systemd/system/timers.target.wants/apt-daily-upgrade.timer \
    /etc/systemd/system/systemd-networkd-wait-online.service

# mask
sh -c 'cd /etc/systemd/system && ln -s /dev/null systemd-networkd-wait-online.service'
###############################################################################

# remove deb packages #########################################################
apt remove -y \
    mdadm \
    ntfs-3g \
    popularity-contest \
    snapd \
    unattended-upgrades \
    update-manager-core

apt autoremove -y
###############################################################################

# remove snap related configurations ##########################################
rm -f \
    /etc/apparmor.d/usr.lib.snapd.snap-confine.real \
    /etc/systemd/system/multi-user.target.wants/snap.lxd.activate.service
###############################################################################

# setup first boot script #####################################################
if [ -d /custom/firstboot ]; then

mkdir -p /opt
mv /custom/firstboot /opt

cat >/etc/systemd/system/firstboot.service <<EOF
[Unit]
Description=First Boot Setup

[Service]
Type=oneshot
ExecStart=/bin/sh /opt/firstboot/delay-exec.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl enable firstboot.service

fi  # if [ -d /custom/firstboot ]; then
###############################################################################
