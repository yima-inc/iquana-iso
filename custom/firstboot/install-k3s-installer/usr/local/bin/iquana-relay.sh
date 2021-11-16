#!/bin/sh

set -e -x

. /etc/default/iquana

[ -z "${BIND_ADDRESS}" ] && exit 1
[ -z "${NODE_EXTERNAL_IP}" ] && exit 1

exec socat TCP-LISTEN:6443,fork,bind=${NODE_EXTERNAL_IP} TCP:${BIND_ADDRESS}:6443
