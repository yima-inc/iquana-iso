#!/bin/sh

set -e -x

[ `id -u` -eq 0 ] || exit 1

UPSTREAM=/usr/share/k3s

mkdir -p /usr/local/bin
cp ${UPSTREAM}/k3s /usr/local/bin/
chmod +x /usr/local/bin/k3s

mkdir -p /var/lib/rancher/k3s/agent/images/
cp ${UPSTREAM}/k3s-airgap-images-amd64.tar.gz /var/lib/rancher/k3s/agent/images/

for ARCHIVE in /usr/share/iquana/custom-images/*.tar.gz; do
    cp ${ARCHIVE} /var/lib/rancher/k3s/agent/images/
done
