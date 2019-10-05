#!/usr/bin/env bash
### every exit != 0 fails the script
set -e
echo "Downloading Tomcat-$TOMCAT_FLAVOR"
source $INST_SCRIPTS/commonFunctions.sh
rm -f "$TOMCAT_FLAVOR.tar.gz"
retry wget "https://www-eu.apache.org/dist/tomcat/tomcat-8/v8.5.40/bin/$TOMCAT_FLAVOR.tar.gz" --quiet
retry wget "https://www.apache.org/dist/tomcat/tomcat-8/v8.5.40/bin/$TOMCAT_FLAVOR.tar.gz.asc" --quiet
sha256=$(sha256sum -b $TOMCAT_FLAVOR.tar.gz)
a=($(echo "$sha256" | tr ' ' '\n'))
sha256toCheck="${a[0]}"
#You have to be kidding - ERROR: cannot verify checker.apache.org's certificate
result=$(wget -qO- https://checker.apache.org/sums/$sha256toCheck --no-check-certificate)

if [[ $result = *"$sha256toCheck"* ]]
then
	echo "SHA256 Check Succeeded"
else
	echo "!!! SHA256 Check Failed !!!"
	exit 1
fi

mkdir $HOME/.gnupg
rm -f $HOME/.gnupg/dirmngr.conf
echo "disable-ipv6" >> $HOME/.gnupg/dirmngr.conf
retry gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 10C01C5A2F6059E7

signature=$(gpg --keyid-format long --verify "$TOMCAT_FLAVOR.tar.gz.asc" "$TOMCAT_FLAVOR.tar.gz" 2>&1)
echo "$signature"
if [[ $signature = *"gpg: Good signature from"* && $signature = *"A9C5DF4D22E99998D9875A5110C01C5A2F6059E7"* ]]
then
	#TODO check file md5 signature wget https://checker.apache.org/sums/932d1b32bde9ea753cb017d73b92258e11cfb3f41a0df0a5263ee1ac67619259 --no-check-certificate #You have to be kidding me! 
#Stage for install to mounted volume upon first user logon
	mv "$TOMCAT_FLAVOR.tar.gz" $HOME/.dockerDevTools/archives
	mv "$TOMCAT_FLAVOR.tar.gz.asc" $HOME/.dockerDevTools/archives
else
	echo "!!! Signature Failed !!!"
	exit 1
fi

