# shellcheck shell=bash
# languages/php - PHP CLI + common extensions (apt), and Composer (verified).

log "Installing PHP CLI and common extensions (apt)"
apt_install php php-cli php-mbstring php-xml php-curl unzip

log "Installing Composer (signature-verified installer)"
composer_setup="/tmp/composer-setup.php"
download "https://getcomposer.org/installer" "${composer_setup}"

# Composer publishes the expected installer SHA-384 over HTTPS; verify before run.
expected_sig="$(retry wget -qO- "https://composer.github.io/installer.sig")"
actual_sig="$(php -r "echo hash_file('sha384', '${composer_setup}');")"
[[ "${actual_sig}" == "${expected_sig}" ]] \
  || die "Composer installer SHA-384 mismatch: got ${actual_sig}, expected ${expected_sig}"
log "SHA-384 verified: ${composer_setup}"

php "${composer_setup}" --install-dir=/usr/local/bin --filename=composer
rm -f "${composer_setup}"
