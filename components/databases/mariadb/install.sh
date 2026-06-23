# shellcheck shell=bash
# databases/mariadb - MariaDB server and client.
# Installs the engine into the dev desktop; a developer starts it on demand
# (e.g. `sudo service mariadb start`), it is not auto-started.
# NOTE: do not combine with databases/mysql in the same stack - the two
# provide conflicting packages.

log "Installing MariaDB server + client (apt, signed distro repo)"
apt_install mariadb-server mariadb-client
