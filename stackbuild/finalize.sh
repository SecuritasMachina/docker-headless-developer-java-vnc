#!/usr/bin/env bash
#
# stackbuild/finalize.sh - last build step for every generated image.
# Trims apt caches and build-time scratch so the published layer stays lean.
set -euo pipefail

echo "=== [stackbuild] finalize: cleaning up ==="
apt-get autoremove -y || true
apt-get clean -y || true
rm -rf /var/lib/apt/lists/*
rm -f  /tmp/.stackbuild-apt-updated
rm -rf /tmp/.stackbuild-gnupg
rm -f  /root/.wget-hsts || true
