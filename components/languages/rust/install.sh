# shellcheck shell=bash
# languages/rust - rustup installed system-wide and non-interactively into /opt/rust.

export RUSTUP_HOME=/opt/rust
export CARGO_HOME=/opt/rust

log "Installing Rust via rustup (system-wide under /opt/rust)"
rustup_init="/tmp/rustup-init.sh"
download "https://sh.rustup.rs" "${rustup_init}"
retry sh "${rustup_init}" -y --no-modify-path
rm -f "${rustup_init}"

cat > /etc/profile.d/rust.sh <<'PROFILE'
export RUSTUP_HOME=/opt/rust
export CARGO_HOME=/opt/rust
export PATH="/opt/rust/bin:${PATH}"
PROFILE

# Make the toolchain available on the default PATH too.
for bin in rustc cargo rustup rustfmt clippy-driver cargo-clippy rustdoc; do
  [[ -x "/opt/rust/bin/${bin}" ]] && ln -sf "/opt/rust/bin/${bin}" "/usr/local/bin/${bin}"
done

# rustup writes a user-readable layout; ensure non-root users can use it.
chmod -R a+rX /opt/rust
