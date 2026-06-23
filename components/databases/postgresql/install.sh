# shellcheck shell=bash
# databases/postgresql - PostgreSQL server, contrib extensions, and client.
# Installs the engine into the dev desktop; a developer starts it on demand
# (e.g. `sudo service postgresql start`), it is not auto-started.

log "Installing PostgreSQL server + contrib + client (apt, signed distro repo)"
apt_install postgresql postgresql-contrib postgresql-client
