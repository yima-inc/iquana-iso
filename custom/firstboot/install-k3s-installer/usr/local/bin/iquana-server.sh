#!/bin/sh

set -e -x

[ `id -u` -eq 0 ] || exit 1

UPSTREAM=/usr/share/k3s

/usr/local/bin/iquana-prepare.sh

. /etc/default/iquana

[ -z "${K3S_NODE_NAME}" ] && exit 1

[ -z "${BIND_ADDRESS}" ] && exit 1
[ -z "${FLANNEL_IFACE}" ] && exit 1
[ -z "${NODE_EXTERNAL_IP}" ] && exit 1

export INSTALL_K3S_SKIP_DOWNLOAD=true
export K3S_NODE_NAME

INSTALL_OPTS="--kube-apiserver-arg default-not-ready-toleration-seconds=30"
INSTALL_OPTS="${INSTALL_OPTS} --kube-apiserver-arg default-unreachable-toleration-seconds=30"
INSTALL_OPTS="${INSTALL_OPTS} --kube-controller-manager-arg node-monitor-grace-period=15s"
INSTALL_OPTS="${INSTALL_OPTS} --kube-controller-manager-arg node-monitor-period=5s"
INSTALL_OPTS="${INSTALL_OPTS} --kube-controller-manager-arg pod-eviction-timeout=30s"
INSTALL_OPTS="${INSTALL_OPTS} --kubelet-arg node-status-update-frequency=10s"
INSTALL_OPTS="${INSTALL_OPTS} --flannel-iface ${FLANNEL_IFACE}"
INSTALL_OPTS="${INSTALL_OPTS} --node-external-ip ${NODE_EXTERNAL_IP}"
INSTALL_OPTS="${INSTALL_OPTS} --bind-address ${BIND_ADDRESS}"
INSTALL_OPTS="${INSTALL_OPTS} --advertise-address ${BIND_ADDRESS}"

if ! [ -z "${NODE_LABELS}" ]; then
    OIFS="${IFS}"
    IFS=:

    for NODE_LABEL in "${NODE_LABELS}"; do
        INSTALL_OPTS="${INSTALL_OPTS} --node-label ${NODE_LABEL}"
    done

    IFS="${OIFS}"
fi

sh ${UPSTREAM}/install.sh ${INSTALL_OPTS}
