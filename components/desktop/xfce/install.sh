# shellcheck shell=bash
# desktop/xfce - Xfce4 desktop environment + fonts.

log "Installing Xfce4 desktop environment"
apt_install $(grep -vE '^\s*#|^\s*$' "${COMPONENT_DIR}/packages.lst")

# Trim power/screensaver bits that are useless (and noisy) in a container.
apt-get purge -y pm-utils 'xscreensaver*' 2>/dev/null || true
