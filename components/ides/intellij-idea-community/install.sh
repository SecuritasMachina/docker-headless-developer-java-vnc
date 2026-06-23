# shellcheck shell=bash
# ides/intellij-idea-community - JetBrains IntelliJ IDEA Community Edition.
#
# Downloaded as a verified tar.gz from download.jetbrains.com. JetBrains
# publishes the official SHA-256 next to the artifact (URL + ".sha256"), in
# "<hex> *<filename>" form, so we fetch and gate on it.
#
# NOTE: as of the 2025.3 line JetBrains dropped the legacy "ideaIC-" filename
# prefix; the current artifact is "idea-${IDEA_VERSION}.tar.gz".

IDEA_VERSION="${IDEA_VERSION:-2025.3}"

log "Installing IntelliJ IDEA Community ${IDEA_VERSION} (verified SHA-256)"

idea_url="https://download.jetbrains.com/idea/idea-${IDEA_VERSION}.tar.gz"
idea_tgz="/tmp/idea-${IDEA_VERSION}.tar.gz"

download "${idea_url}" "${idea_tgz}"
# The .sha256 file is "<hex> *<filename>" - keep only the hex digest.
idea_sha="$(retry wget -qO- "${idea_url}.sha256" | awk '{print $1}')"
verify_sha256 "${idea_tgz}" "${idea_sha}"

# The tarball extracts to a single versioned top-level dir (e.g. idea-IC-253.xxx);
# extract to a staging dir and relocate that dir to /opt/idea (name-agnostic).
rm -rf /opt/idea /tmp/idea-extract
install -d /tmp/idea-extract
tar -xzf "${idea_tgz}" -C /tmp/idea-extract
extracted="$(find /tmp/idea-extract -maxdepth 1 -mindepth 1 -type d | head -1)"
[[ -n "${extracted}" ]] || die "IntelliJ IDEA archive did not extract a top-level directory"
mv "${extracted}" /opt/idea
rm -rf "${idea_tgz}" /tmp/idea-extract

ln -sfn /opt/idea/bin/idea.sh /usr/local/bin/idea
