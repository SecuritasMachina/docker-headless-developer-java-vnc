# shellcheck shell=bash
# databases/mysql - MySQL server and client.
# Installs the engine into the dev desktop; a developer starts it on demand
# (e.g. `sudo service mysql start`), it is not auto-started.
# NOTE: do not combine with databases/mariadb in the same stack - the two
# provide conflicting packages.

log "Installing MySQL server + client (apt, signed distro repo)"
apt_install mysql-server mysql-client
