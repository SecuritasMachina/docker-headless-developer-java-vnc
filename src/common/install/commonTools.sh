#!/usr/bin/env bash
### every exit != 0 fails the script
set -e
echo "Install common tools for further installation"
apt-get install -y $(awk -F: '/^[^#]/ { print $1 }' $INST_SCRIPTS/package.lst) 
