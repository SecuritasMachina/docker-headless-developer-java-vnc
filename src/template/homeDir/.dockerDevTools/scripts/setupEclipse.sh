#!/usr/bin/env bash
### every exit != 0 fails the script
set -e
if [ -d "$HOME/apps/eclipse" ]
then
        echo "$HOME/apps/eclipse exists, skipping install"
else
	echo "Installing $ECLIPSE_FLAVOR"
	mkdir -p $HOME/apps
	rm -rf "$HOME/apps/eclipse"
	tar -xvzf "$HOME/.dockerDevTools/archives/$ECLIPSE_FLAVOR.tar.gz" -C "$HOME/apps"
fi
