#!/usr/bin/env bash
### every exit != 0 fails the script
set -e
echo "Downloading ~500mb Eclipse-$ECLIPSE_FLAVOR"
source $INST_SCRIPTS/commonFunctions.sh
rm -f "$ECLIPSE_FLAVOR.tar.gz"

# Path of the artifact within the Eclipse mirror tree, e.g.
#   /technology/epp/downloads/release/2026-03/R/eclipse-jee-...tar.gz
ECLIPSE_PATH="/technology/epp/downloads/release/${ECLIPSE_RELEASE}/${ECLIPSE_FLAVOR}.tar.gz"
# URL-encode the slashes for the sums.php query parameter
ECLIPSE_PATH_ENC="${ECLIPSE_PATH//\//%2F}"

retry wget "https://ftp.osuosl.org/pub/eclipse${ECLIPSE_PATH}" --quiet

sha512=$(sha512sum -b $ECLIPSE_FLAVOR.tar.gz)
a=($(echo "$sha512" | tr ' ' '\n'))
sha512toCheck="${a[0]}"
# NOTE: the whole URL MUST be quoted - the unquoted '&' previously backgrounded
# wget and ran "type=sha512" as a separate command, so the check never ran.
result=$(wget -qO- "https://www.eclipse.org/downloads/sums.php?file=${ECLIPSE_PATH_ENC}&type=sha512")

if [[ $result = *"$sha512toCheck"* ]]
then
	echo "SHA512 Check Succeeded"
	#Stage for install to mounted volume upon first user logon
	mv "$ECLIPSE_FLAVOR.tar.gz" $HOME/.dockerDevTools/archives
else
	echo "!!! SHA512 Check Failed !!!"
	exit 1
fi
