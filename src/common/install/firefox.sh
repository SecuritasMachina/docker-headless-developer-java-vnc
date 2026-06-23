#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Firefox from Mozilla's signed APT repository"
source $INST_SCRIPTS/commonFunctions.sh

# The Ubuntu 22.04 'firefox' apt package is a snap transitional shim that does
# not work inside a container (no snapd). Install the real DEB from Mozilla's
# official, signed APT repo instead.
install -d -m 0755 /etc/apt/keyrings
retry wget -qO- https://packages.mozilla.org/apt/repo-signing-key.gpg > /etc/apt/keyrings/packages.mozilla.org.asc

echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" \
    > /etc/apt/sources.list.d/mozilla.list

# Prefer the Mozilla repo over the Ubuntu snap shim
printf 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n' \
    > /etc/apt/preferences.d/mozilla

retry apt-get update
apt-get install -y --no-install-recommends firefox
