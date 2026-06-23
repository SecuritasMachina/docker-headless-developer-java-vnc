# shellcheck shell=bash
# tools/scm - extra source-control clients beyond git (already in base/core).

log "Installing extra source-control clients (Mercurial, Subversion, Git LFS)"
apt_install mercurial subversion git-lfs
