# shellcheck shell=bash
# databases/mongodb - MongoDB Community Server from MongoDB's signed apt repo.
# Installs the engine + shell/tools into the dev desktop; a developer starts it
# on demand (e.g. `sudo service mongod start` or `mongod`), it is not
# auto-started.

MONGODB_VERSION="${MONGODB_VERSION:-7.0}"

log "Registering MongoDB ${MONGODB_VERSION} signed apt repo"
add_apt_repo mongodb-org \
  "https://www.mongodb.org/static/pgp/server-${MONGODB_VERSION}.asc" \
  "deb [ signed-by=/etc/apt/keyrings/mongodb-org.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/${MONGODB_VERSION} multiverse"

log "Installing MongoDB Community Server ${MONGODB_VERSION}"
apt_install mongodb-org
