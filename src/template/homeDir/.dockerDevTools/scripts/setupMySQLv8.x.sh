#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

if [ -d "$HOME/apps/$MYSQL_FLAVOR-linux-glibc2.12-x86_64" ]
then
        echo "$HOME/apps/$MYSQL_FLAVOR-linux-glibc2.12-x86_64 exists, skipping install"
else
	echo "Installing $MYSQL_FLAVOR"
	mkdir -p $HOME/data/mysql
	mkdir -p $HOME/apps

	rm -rf "$HOME/apps/mysql"
	rm -rf "$HOME/apps/$MYSQL_FLAVOR-linux-glibc2.12-x86_64"
	tar -xvf "$HOME/.dockerDevTools/archives/$MYSQL_FLAVOR-linux-glibc2.12-x86_64.tar.xz" -C "$HOME/apps"
fi
if [ -d "$HOME/apps/mysql" ]
then
	echo "Skip $MYSQL_FLAVOR link creation"
else
	echo "Creating link"
	ln -s "$HOME/apps/$MYSQL_FLAVOR-linux-glibc2.12-x86_64" "$HOME/apps/mysql"

fi
