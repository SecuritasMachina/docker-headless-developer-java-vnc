#!/usr/bin/env bash
### every exit != 0 fails the script
set -e
echo "Downloading Tomcat-$TOMCAT_FLAVOR"
source $INST_SCRIPTS/commonFunctions.sh
rm -f "$TOMCAT_FLAVOR.tar.gz" "$TOMCAT_FLAVOR.tar.gz.asc" "$TOMCAT_FLAVOR.tar.gz.sha512"
retry wget "$TOMCAT_DOWNLOAD/$TOMCAT_FLAVOR.tar.gz" --quiet
retry wget "$TOMCAT_DOWNLOAD/$TOMCAT_FLAVOR.tar.gz.asc" --quiet
# Apache publishes the official SHA-512 next to the artifact over HTTPS.
# (The old checker.apache.org check used --no-check-certificate, which disabled
#  TLS verification entirely - removed in favour of the signed checksum file.)
retry wget "$TOMCAT_DOWNLOAD/$TOMCAT_FLAVOR.tar.gz.sha512" --quiet

echo "Verifying SHA-512 checksum"
sha512sum -c "$TOMCAT_FLAVOR.tar.gz.sha512"

mkdir -p $HOME/.gnupg
rm -f $HOME/.gnupg/dirmngr.conf
echo "disable-ipv6" >> $HOME/.gnupg/dirmngr.conf
# Import the full Apache Tomcat KEYS file (covers all release managers) over HTTPS,
# instead of trusting a single hard-coded key id fetched over plaintext hkp://.
retry wget -qO- https://downloads.apache.org/tomcat/tomcat-9/KEYS | gpg --import

signature=$(gpg --keyid-format long --verify "$TOMCAT_FLAVOR.tar.gz.asc" "$TOMCAT_FLAVOR.tar.gz" 2>&1)
echo "$signature"
mv "$TOMCAT_FLAVOR.tar.gz" $HOME/.dockerDevTools/archives
mv "$TOMCAT_FLAVOR.tar.gz.asc" $HOME/.dockerDevTools/archives

if [[ $signature = *"gpg: Good signature from"* ]]
then
	echo "!!! Tomcat Signature Success !!!"
else
	echo "!!! Tomcat Signature Failed !!!"
	exit 1
fi
