# shellcheck shell=bash
# languages/node - Node.js LTS from NodeSource's signed apt repo, plus corepack.

NODE_MAJOR_VERSION="${NODE_MAJOR_VERSION:-22}"

log "Adding NodeSource signed apt repo (Node.js ${NODE_MAJOR_VERSION}.x LTS)"
add_apt_repo "nodesource" \
  "https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key" \
  "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR_VERSION}.x nodistro main"

log "Installing Node.js ${NODE_MAJOR_VERSION}.x"
apt_install nodejs

log "Enabling corepack (yarn + pnpm)"
if command -v corepack >/dev/null 2>&1; then
  corepack enable
  corepack prepare yarn@stable --activate 2>/dev/null || true
  corepack prepare pnpm@latest --activate 2>/dev/null || true
fi
