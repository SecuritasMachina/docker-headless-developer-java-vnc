# shellcheck shell=bash
# databases/sqlite - SQLite 3 command-line tool and development headers.
# SQLite is an embedded library (no server to start); the CLI and the
# libsqlite3-dev headers are installed for building/inspecting databases.

log "Installing SQLite 3 CLI + dev headers (apt, signed distro repo)"
apt_install sqlite3 libsqlite3-dev
