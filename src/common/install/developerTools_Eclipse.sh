#!/usr/bin/env bash
### every exit != 0 fails the script
set -e
echo "Downloading ~500mb Eclipse-$ECLIPSE_FLAVOR"
source $INST_SCRIPTS/commonFunctions.sh
rm -f "$ECLIPSE_FLAVOR.tar.gz"
retry wget "http://ftp.osuosl.org/pub/eclipse/technology/epp/downloads/release/2019-03/R/$ECLIPSE_FLAVOR.tar.gz" --quiet
sha512=$(sha512sum -b $ECLIPSE_FLAVOR.tar.gz)
a=($(echo "$sha512" | tr ' ' '\n'))
sha512toCheck="${a[0]}"
result=$(wget -qO- https://www.eclipse.org/downloads/sums.php?file=%2Ftechnology%2Fepp%2Fdownloads%2Frelease%2F2019-03%2FR%2F$ECLIPSE_FLAVOR.tar.gz&type=sha512)
wget "https://www.eclipse.org/downloads/sums.php?file=%2Ftechnology%2Fepp%2Fdownloads%2Frelease%2F2019-03%2FR%2F$ECLIPSE_FLAVOR.tar.gz&type=sha512" --output-document=eclipse.sig --quiet 
#result="${result//\\//}"
if [[ $result = *"$sha512toCheck"* ]]
then
	echo "SHA512 Check Succeeded"
	rm -f eclipse.sig
	#Stage for install to mounted volume upon first user logon
	mv "$ECLIPSE_FLAVOR.tar.gz" $HOME/.dockerDevTools/archives
	
else
	echo "!!! SHA512 Check Failed !!!"
	exit 1
fi

