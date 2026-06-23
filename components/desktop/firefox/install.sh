# shellcheck shell=bash
# desktop/firefox - Firefox from Mozilla's signed APT repo.
#
# The Ubuntu 22.04 'firefox' apt package is a snap transitional shim that does
# not work inside a container (no snapd). Install the real DEB from Mozilla's
# official, signed APT repo instead, pinned above the Ubuntu snap shim.

log "Adding Mozilla signed APT repository"
add_apt_repo mozilla \
  "https://packages.mozilla.org/apt/repo-signing-key.gpg" \
  "deb [signed-by=/etc/apt/keyrings/mozilla.gpg] https://packages.mozilla.org/apt mozilla main"

log "Pinning Mozilla repo above the Ubuntu snap shim"
printf 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n' \
  > /etc/apt/preferences.d/mozilla

log "Installing Firefox"
apt_install firefox
