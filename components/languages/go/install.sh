# shellcheck shell=bash
# languages/go - official Go tarball, SHA-256 verified, extracted to /usr/local.

GO_VERSION="${GO_VERSION:-1.24.4}"

log "Installing Go ${GO_VERSION} (verified official tarball)"
go_tarball="/tmp/go${GO_VERSION}.linux-amd64.tar.gz"
download "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" "${go_tarball}"

# go.dev publishes signed release metadata as JSON; pull the official sha256 for
# this exact archive and gate on it (never trust the download blindly).
go_sha="$(retry wget -qO- "https://go.dev/dl/?mode=json&include=all" \
  | grep -A4 "\"go${GO_VERSION}.linux-amd64.tar.gz\"" \
  | grep '"sha256"' \
  | head -n1 \
  | sed -E 's/.*"sha256": *"([0-9a-f]+)".*/\1/')"
[[ -n "${go_sha}" ]] || die "could not resolve official SHA-256 for Go ${GO_VERSION}"
verify_sha256 "${go_tarball}" "${go_sha}"

rm -rf /usr/local/go
tar -C /usr/local -xzf "${go_tarball}"
rm -f "${go_tarball}"

cat > /etc/profile.d/go.sh <<'PROFILE'
export PATH="/usr/local/go/bin:${PATH}"
PROFILE
ln -sf /usr/local/go/bin/go /usr/local/bin/go
ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt
