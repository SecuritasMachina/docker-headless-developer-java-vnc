# shellcheck shell=bash
# base/security - ClamAV antivirus (with initial signature DBs) + Lynis hardening.

log "Installing ClamAV and Lynis (apt)"
apt_install clamav clamav-daemon clamav-freshclam lynis

log "Downloading initial ClamAV signature databases (HTTPS)"
download "https://database.clamav.net/main.cvd"     /var/lib/clamav/main.cvd
download "https://database.clamav.net/daily.cvd"    /var/lib/clamav/daily.cvd
download "https://database.clamav.net/bytecode.cvd" /var/lib/clamav/bytecode.cvd

log "Setting ClamAV ownership and runtime/log directories"
chown -R clamav:clamav /var/lib/clamav

install -d -o clamav -g clamav -m 0755 /var/log/clamav
install -d -o clamav -g clamav -m 0755 /var/run/clamav
