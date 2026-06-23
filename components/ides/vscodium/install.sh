# shellcheck shell=bash
# ides/vscodium - VSCodium (open-source VS Code) from its signed apt repository.

log "Adding the VSCodium signed apt repository"
add_apt_repo vscodium \
  "https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg" \
  "deb [signed-by=/etc/apt/keyrings/vscodium.gpg] https://download.vscodium.com/debs vscodium main"

log "Installing VSCodium (codium)"
apt_install codium
