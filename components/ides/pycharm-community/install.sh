# shellcheck shell=bash
# ides/pycharm-community - JetBrains PyCharm Community Edition.
#
# Downloaded as a verified tar.gz from download.jetbrains.com. JetBrains
# publishes the official SHA-256 next to the artifact (URL + ".sha256"), in
# "<hex> *<filename>" form, so we fetch and gate on it.
#
# Pairs well with languages/python (not a hard dependency - PyCharm bundles its
# own runtime), so it is intentionally NOT in REQUIRES.
#
# NOTE: as of the 2025.3 line JetBrains dropped the legacy "pycharm-community-"
# filename prefix; the current artifact is "pycharm-${PYCHARM_VERSION}.tar.gz".

PYCHARM_VERSION="${PYCHARM_VERSION:-2025.3}"

log "Installing PyCharm Community ${PYCHARM_VERSION} (verified SHA-256)"

pycharm_url="https://download.jetbrains.com/python/pycharm-${PYCHARM_VERSION}.tar.gz"
pycharm_tgz="/tmp/pycharm-${PYCHARM_VERSION}.tar.gz"

download "${pycharm_url}" "${pycharm_tgz}"
# The .sha256 file is "<hex> *<filename>" - keep only the hex digest.
pycharm_sha="$(retry wget -qO- "${pycharm_url}.sha256" | awk '{print $1}')"
verify_sha256 "${pycharm_tgz}" "${pycharm_sha}"

# The tarball extracts to a single versioned top-level dir (e.g. pycharm-PC-253.xxx);
# extract to a staging dir and relocate it to /opt/pycharm (name-agnostic).
rm -rf /opt/pycharm /tmp/pycharm-extract
install -d /tmp/pycharm-extract
tar -xzf "${pycharm_tgz}" -C /tmp/pycharm-extract
extracted="$(find /tmp/pycharm-extract -maxdepth 1 -mindepth 1 -type d | head -1)"
[[ -n "${extracted}" ]] || die "PyCharm archive did not extract a top-level directory"
mv "${extracted}" /opt/pycharm
rm -rf "${pycharm_tgz}" /tmp/pycharm-extract

ln -sfn /opt/pycharm/bin/pycharm.sh /usr/local/bin/pycharm
