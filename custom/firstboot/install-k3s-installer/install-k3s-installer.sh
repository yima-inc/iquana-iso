#!/bin/sh

set -e -x

FILES=etc/default/iquana
FILES=${FILES}:lib/systemd/system/iquana-relay.service
FILES=${FILES}:usr/local/bin/iquana-agent.sh
FILES=${FILES}:usr/local/bin/iquana-prepare.sh
FILES=${FILES}:usr/local/bin/iquana-relay.sh
FILES=${FILES}:usr/local/bin/iquana-reset.sh
FILES=${FILES}:usr/local/bin/iquana-server.sh
FILES=${FILES}:usr/share/k3s/k3s
FILES=${FILES}:usr/share/k3s/k3s-airgap-images-amd64.tar.gz
FILES=${FILES}:usr/share/k3s/install.sh

OIFS="${IFS}"

IFS=:
for FILE in ${FILES}; do
    mkdir -p `dirname /${FILE}`

    cp ${PWD}/${FILE} /${FILE}
done

IFS="${OIFS}"

chmod +x \
    /usr/local/bin/iquana-agent.sh \
    /usr/local/bin/iquana-prepare.sh \
    /usr/local/bin/iquana-relay.sh \
    /usr/local/bin/iquana-reset.sh \
    /usr/local/bin/iquana-server.sh
