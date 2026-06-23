# shellcheck shell=bash
# tools/build-essential - common native build toolchain.

log "Installing native build toolchain (build-essential, cmake, autoconf, ant, ...)"
apt_install build-essential cmake make autoconf pkg-config ant
