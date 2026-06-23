# shellcheck shell=bash
# servers/nginx - nginx HTTP server / reverse proxy from Ubuntu's signed apt repo.

log "Installing nginx (apt, signed repo)"
apt_install nginx
