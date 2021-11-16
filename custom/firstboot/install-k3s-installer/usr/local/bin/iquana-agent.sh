#!/bin/sh

set -e -x

[ `id -u` -eq 0 ] || exit 1

UPSTREAM=/usr/share/k3s

/usr/local/bin/iquana-prepare.sh

. /etc/default/iquana

[ -z "${K3S_NODE_NAME}" ] && exit 1
[ -z "${K3S_URL}" ] && exit 1
[ -z "${K3S_TOKEN}" ] && exit 1

[ -z "${FLANNEL_IFACE}" ] && exit 1

export INSTALL_K3S_SKIP_DOWNLOAD=true
export K3S_NODE_NAME
export K3S_URL
export K3S_TOKEN

INSTALL_OPTS="--kubelet-arg node-status-update-frequency=10s"
INSTALL_OPTS="${INSTALL_OPTS} --flannel-iface ${FLANNEL_IFACE}"

if ! [ -z "${NODE_EXTERNAL_IP}" ]; then
    INSTALL_OPTS="${INSTALL_OPTS} --node-external-ip ${NODE_EXTERNAL_IP}"
fi

if ! [ -z "${NODE_LABELS}" ]; then
    OIFS="${IFS}"
    IFS=:

    for NODE_LABEL in "${NODE_LABELS}"; do
        INSTALL_OPTS="${INSTALL_OPTS} --node-label ${NODE_LABEL}"
    done

    IFS="${OIFS}"
fi

sh ${UPSTREAM}/install.sh ${INSTALL_OPTS}
