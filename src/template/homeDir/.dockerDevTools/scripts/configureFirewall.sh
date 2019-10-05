#!/usr/bin/env bash
echo "Configure Firewall, force traffic to go through proxy"
### every exit != 0 fails the script
set -e
ufw default deny outgoing
ufw default deny incoming
ufw allow 5901
ufw allow 6901
ufw allow out 53
ufw allow out 3128
ufw enable

service squid-deb-proxy start
