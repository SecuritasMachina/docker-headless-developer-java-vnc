# shellcheck shell=bash
# databases/redis - Redis server and CLI tools.
# Installs the engine into the dev desktop; a developer starts it on demand
# (e.g. `sudo service redis-server start` or `redis-server`), it is not
# auto-started.

log "Installing Redis server + tools (apt, signed distro repo)"
apt_install redis-server redis-tools
