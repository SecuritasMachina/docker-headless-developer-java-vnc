# shellcheck shell=bash
# languages/python - Python 3 toolchain (apt): pip, venv, dev headers, pipx.

log "Installing Python 3 toolchain (apt)"
apt_install python3 python3-pip python3-venv python3-dev pipx build-essential
