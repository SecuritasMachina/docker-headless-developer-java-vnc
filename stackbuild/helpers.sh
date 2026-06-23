#!/usr/bin/env bash
#
# stackbuild/helpers.sh
# ---------------------
# Shared build-time helper API sourced by every component's install.sh.
# Provides consistent, hardened primitives so individual components stay small
# and so security practices (signed repos, checksum/signature verification,
# retries, apt-update-once) are applied uniformly.
#
# This file is sourced inside the image during `docker build`, as root.

set -euo pipefail

# --- logging ---------------------------------------------------------------
log()  { echo -e "\n=== [stackbuild] $* ==="; }
warn() { echo "WARN [stackbuild] $*" >&2; }
die()  { echo "ERROR [stackbuild] $*" >&2; exit 1; }

# --- retry wrapper ---------------------------------------------------------
# retry <cmd...>  - retry a flaky (usually network) command a bounded number
# of times with a fixed delay before giving up.
retry() {
  local -i n=1 max=5 delay=5
  while true; do
    if "$@"; then return 0; fi
    if (( n >= max )); then
      die "command failed after ${n} attempts: $*"
    fi
    warn "attempt ${n}/${max} failed: $* (retrying in ${delay}s)"
    (( n++ ))
    sleep "${delay}"
  done
}

# --- apt -------------------------------------------------------------------
_APT_UPDATED_SENTINEL=/tmp/.stackbuild-apt-updated

apt_update_once() {
  if [[ ! -f "${_APT_UPDATED_SENTINEL}" ]]; then
    retry apt-get update
    touch "${_APT_UPDATED_SENTINEL}"
  fi
}

# Force a re-read of apt sources on the next apt_install (call after adding a repo).
apt_invalidate() { rm -f "${_APT_UPDATED_SENTINEL}"; }

# apt_install <pkg...>  - install packages without recommends.
apt_install() {
  [[ $# -gt 0 ]] || return 0
  export DEBIAN_FRONTEND=noninteractive
  apt_update_once
  retry apt-get install -y --no-install-recommends "$@"
}

# add_apt_repo <name> <key_url> <sources_line>
# Registers a third-party APT repository the modern, secure way: the signing
# key is fetched over HTTPS into /etc/apt/keyrings and the source line is
# pinned to it via signed-by= (never apt-key, never an unsigned repo).
add_apt_repo() {
  local name="$1" key_url="$2" sources_line="$3"
  install -d -m 0755 /etc/apt/keyrings
  local keyring="/etc/apt/keyrings/${name}.gpg"
  retry wget -qO- "${key_url}" | gpg --dearmor -o "${keyring}"
  echo "${sources_line}" > "/etc/apt/sources.list.d/${name}.list"
  apt_invalidate
}

# --- downloads & verification ---------------------------------------------
# download <url> <out>
download() { retry wget -q -O "$2" "$1"; }

# verify_sha256 <file> <expected_hex>
verify_sha256() {
  local file="$1" expected="$2" actual
  actual="$(sha256sum -b "${file}" | awk '{print $1}')"
  [[ "${actual}" == "${expected}" ]] || die "SHA-256 mismatch for ${file}: got ${actual}, expected ${expected}"
  log "SHA-256 verified: ${file}"
}

# verify_sha512 <file> <expected_hex>
verify_sha512() {
  local file="$1" expected="$2" actual
  actual="$(sha512sum -b "${file}" | awk '{print $1}')"
  [[ "${actual}" == "${expected}" ]] || die "SHA-512 mismatch for ${file}: got ${actual}, expected ${expected}"
  log "SHA-512 verified: ${file}"
}

# gpg_verify <signature_file> <data_file> <keys_url>
# Imports the vendor public key(s) from an HTTPS URL and verifies a detached
# signature. Aborts the build on a bad/absent signature.
gpg_verify() {
  local sig="$1" data="$2" keys_url="$3"
  export GNUPGHOME="${GNUPGHOME:-/tmp/.stackbuild-gnupg}"
  install -d -m 0700 "${GNUPGHOME}"
  retry wget -qO- "${keys_url}" | gpg --import
  if gpg --verify "${sig}" "${data}" 2>&1 | grep -q "Good signature"; then
    log "GPG signature verified: ${data}"
  else
    die "GPG signature verification FAILED for ${data}"
  fi
}

# --- desktop integration ---------------------------------------------------
# install_desktop_launchers <component_dir>
# Copies any *.desktop files shipped by a component onto the skeleton Desktop
# so they appear for the container user.
install_desktop_launchers() {
  local dir="$1/desktop"
  [[ -d "${dir}" ]] || return 0
  install -d -m 0755 /etc/skel/Desktop
  cp -v "${dir}"/*.desktop /etc/skel/Desktop/ 2>/dev/null || true
  chmod a+x /etc/skel/Desktop/*.desktop 2>/dev/null || true
}
