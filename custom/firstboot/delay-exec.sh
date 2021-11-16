#!/bin/sh

echo 'initializing...' >>/var/log/firstboot.log
sleep 60

bash /opt/firstboot/firstboot.sh >>/var/log/firstboot.log 2>&1
