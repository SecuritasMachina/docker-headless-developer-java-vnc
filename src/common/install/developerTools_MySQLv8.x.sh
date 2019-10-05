#!/usr/bin/env bash
### every exit != 0 fails the script
set -e
echo "Downloading ~400mb MySQL-$MYSQL_FLAVOR"
source $INST_SCRIPTS/commonFunctions.sh
rm -f "$MYSQL_FLAVOR-linux-glibc2.12-x86_64.tar.xz"
retry wget "https://dev.mysql.com/get/Downloads/MySQL-8.0/$MYSQL_FLAVOR-linux-glibc2.12-x86_64.tar.xz" --quiet
retry wget "https://dev.mysql.com/downloads/gpg/?file=mysql-8.0.15-linux-glibc2.12-x86_64.tar.xz"  --output-document=mysql.sig --quiet

mkdir $HOME/.gnupg
rm -f $HOME/.gnupg/dirmngr.conf
echo "disable-ipv6" >> $HOME/.gnupg/dirmngr.conf
retry gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 8C718D3B5072E1F5

signature=$(gpg --keyid-format long --verify "mysql.sig" "$MYSQL_FLAVOR-linux-glibc2.12-x86_64.tar.xz" 2>&1)
echo "$signature"
if [[ $signature = *"gpg: Good signature from"* && $signature = *"8C718D3B5072E1F5"* ]]
then
#Stage for install to mounted volume upon first user logon
	mv "$MYSQL_FLAVOR-linux-glibc2.12-x86_64.tar.xz" $HOME/.dockerDevTools/archives
	mv "mysql.sig" $HOME/.dockerDevTools/archives
else
	echo "!!! Signature Failed !!!"
	exit 1
fi

