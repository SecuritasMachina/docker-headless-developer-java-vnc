# shellcheck shell=bash
# databases/dbeaver - DBeaver Community Edition (universal database GUI) from
# DBeaver's signed apt repo. A desktop launcher is shipped under desktop/ and
# installed automatically by run-component.sh.

log "Registering DBeaver signed apt repo"
add_apt_repo dbeaver \
  "https://dbeaver.io/debs/dbeaver.gpg.key" \
  "deb [signed-by=/etc/apt/keyrings/dbeaver.gpg] https://dbeaver.io/debs/dbeaver-ce /"

log "Installing DBeaver Community Edition"
apt_install dbeaver-ce
