# shellcheck shell=bash
# tools/docker-cli - Docker CLI client (no daemon) from Docker's signed apt repo.

log "Adding Docker signed apt repo"
add_apt_repo "docker" \
  "https://download.docker.com/linux/ubuntu/gpg" \
  "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable"

log "Installing Docker CLI + compose/buildx plugins"
apt_install docker-ce-cli docker-compose-plugin docker-buildx-plugin
