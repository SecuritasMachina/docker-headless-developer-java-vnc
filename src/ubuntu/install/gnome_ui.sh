#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Gnome UI components"
source $INST_SCRIPTS/commonFunctions.sh
retry apt-get install -y supervisor gnome-core xfce4 xfce4-terminal xterm
apt-get purge -y pm-utils xscreensaver*
apt-get clean -y