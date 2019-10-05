#!/usr/bin/env bash
echo "Configure Firewall, force traffic to go through proxy"

ufw default deny outgoing
ufw default deny incoming
ufw allow 5901
ufw allow 6901
ufw allow out 53
ufw allow out 3128
ufw enable
