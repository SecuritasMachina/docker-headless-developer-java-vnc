#!/usr/bin/env bash
### every exit != 0 fails the script
set -e
if [ -d "$HOME/apps/$TOMCAT_FLAVOR" ]
then
        echo "$HOME/apps/$TOMCAT_FLAVOR exists, skipping install"
else
	echo "Installing $TOMCAT_FLAVOR"
	mkdir -p $HOME/apps
	rm -rf "$HOME/apps/tomcat"
	rm -rf "$HOME/apps/$TOMCAT_FLAVOR"
	tar -xzf "$HOME/.dockerDevTools/archives/$TOMCAT_FLAVOR.tar.gz" -C "$HOME/apps"

fi
if [ -d "$HOME/apps/tomcat" ]
then
	echo "Skip $TOMCAT_FLAVOR link creation"
else
	echo "Creating link"
	ln -s "$HOME/apps/$TOMCAT_FLAVOR" "$HOME/apps/tomcat"
fi
