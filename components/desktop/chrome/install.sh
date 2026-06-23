# shellcheck shell=bash
# desktop/chrome - Google Chrome from Google's signed APT repo.

log "Adding Google Chrome signed APT repository"
add_apt_repo google-chrome \
  "https://dl.google.com/linux/linux_signing_key.pub" \
  "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main"

log "Installing Google Chrome"
apt_install google-chrome-stable
