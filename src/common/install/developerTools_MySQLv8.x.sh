#!/usr/bin/env bash
### every exit != 0 fails the script
set -e
echo "Downloading ~400mb MySQL-$MYSQL_FLAVOR"
source $INST_SCRIPTS/commonFunctions.sh

MYSQL_TARBALL="$MYSQL_FLAVOR-linux-$MYSQL_GLIBC-x86_64.tar.xz"
rm -f "$MYSQL_TARBALL" mysql.sig
retry wget "https://dev.mysql.com/get/Downloads/MySQL-8.0/$MYSQL_TARBALL" --quiet
retry wget "https://dev.mysql.com/downloads/gpg/?file=$MYSQL_TARBALL"  --output-document=mysql.sig --quiet

mkdir -p $HOME/.gnupg
rm -f $HOME/.gnupg/dirmngr.conf
echo "disable-ipv6" >> $HOME/.gnupg/dirmngr.conf
# Import MySQL's current release signing key from Oracle over HTTPS instead of a
# stale hard-coded key id fetched over plaintext hkp:// (the key rotates).
retry wget -qO- https://repo.mysql.com/RPM-GPG-KEY-mysql-2023 | gpg --import

signature=$(gpg --keyid-format long --verify "mysql.sig" "$MYSQL_TARBALL" 2>&1)
echo "$signature"
if [[ $signature = *"gpg: Good signature from"* ]]
then
#Stage for install to mounted volume upon first user logon
	mv "$MYSQL_TARBALL" $HOME/.dockerDevTools/archives
	mv "mysql.sig" $HOME/.dockerDevTools/archives
else
	echo "!!! MySQL Signature Failed !!!"
	exit 1
fi
