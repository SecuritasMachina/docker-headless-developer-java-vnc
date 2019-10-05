#!/usr/bin/env bash
echo "Configure Security"
### every exit != 0 fails the script
set -e
#chown root:root /usr/bin/sudo && chmod 4755 /usr/bin/sudo

chown root:root /etc/sudoers
chmod 0440 /etc/sudoers

chown root:root /etc/sudoers.d/*
chmod 0440 /etc/sudoers.d/*

chmod -R a-rwx /etc/modprobe.d
chmod -R ug+rw /etc/modprobe.d

chmod a-rwx /lib/systemd/system/ufw.service
chmod a+r /lib/systemd/system/ufw.service
chmod u+rw /lib/systemd/system/ufw.service


#chmod -R a-rwx /etc/squid
#chmod -R ug+rw /etc/squid
#chmod -R a-rwx /etc/squid-deb-proxy
#chmod -R ug+rw /etc/squid-deb-proxy

chmod -R a-rwx /etc/ufw
chmod -R ug+rw /etc/ufw

chmod a-rwx /etc/login.defs
chmod u+rw /etc/login.defs

chgrp clamav /etc/clamav/*.conf
chmod a-w /etc/clamav
chmod ug+r /etc/clamav
chmod u+wx /etc/clamav
chmod a+rx /etc/clamav


