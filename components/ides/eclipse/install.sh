# shellcheck shell=bash
# ides/eclipse - Eclipse IDE for Enterprise Java and Web Developers (JEE).
#
# Refactored from the repo's modernized installer
# (src/common/install/developerTools_Eclipse.sh) into a self-contained
# component. Downloaded over HTTPS from the OSU Open Source Lab mirror and
# gated against the official SHA-512 served by eclipse.org/downloads/sums.php.

ECLIPSE_RELEASE="${ECLIPSE_RELEASE:-2026-03/R}"
ECLIPSE_FLAVOR="${ECLIPSE_FLAVOR:-eclipse-jee-2026-03-R-linux-gtk-x86_64}"

log "Installing Eclipse IDE (${ECLIPSE_FLAVOR}, verified SHA-512)"

# Path of the artifact within the Eclipse mirror tree.
eclipse_path="/technology/epp/downloads/release/${ECLIPSE_RELEASE}/${ECLIPSE_FLAVOR}.tar.gz"
eclipse_url="https://ftp.osuosl.org/pub/eclipse${eclipse_path}"
eclipse_tgz="/tmp/${ECLIPSE_FLAVOR}.tar.gz"

download "${eclipse_url}" "${eclipse_tgz}"

# Fetch the official SHA-512. The whole sums.php URL MUST be quoted - an
# unquoted '&' previously backgrounded wget and ran "type=sha512" as a separate
# command, so the check never actually ran (known historical bug).
eclipse_path_enc="${eclipse_path//\//%2F}"
eclipse_sha="$(retry wget -qO- "https://www.eclipse.org/downloads/sums.php?file=${eclipse_path_enc}&type=sha512" | awk '{print $1}')"
[[ -n "${eclipse_sha}" ]] || die "could not fetch Eclipse SHA-512 from sums.php"
verify_sha512 "${eclipse_tgz}" "${eclipse_sha}"

# The tarball extracts to a single top-level "eclipse/" directory -> /opt/eclipse.
rm -rf /opt/eclipse
tar -xzf "${eclipse_tgz}" -C /opt
rm -f "${eclipse_tgz}"

[[ -x /opt/eclipse/eclipse ]] || die "Eclipse did not extract to /opt/eclipse"
ln -sfn /opt/eclipse/eclipse /usr/local/bin/eclipse
