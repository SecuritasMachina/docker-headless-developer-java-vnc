# shellcheck shell=bash
# languages/ruby - Ruby (full) toolchain (apt) plus Bundler.

log "Installing Ruby toolchain (apt)"
apt_install ruby-full ruby-dev build-essential

log "Installing Bundler (gem)"
retry gem install bundler --no-document
