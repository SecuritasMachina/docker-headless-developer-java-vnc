# shellcheck shell=bash
# ides/netbeans - Apache NetBeans IDE.
#
# Downloaded as the official binary zip from an Apache CDN mirror (dlcdn) and
# gated against the official SHA-512 published on downloads.apache.org. The
# .sha512 file is "<hex>  ./<filename>" form, so we keep only the hex digest.
# The zip extracts to a single top-level "netbeans/" directory -> /opt/netbeans.

NB_VERSION="${NB_VERSION:-30}"

log "Installing Apache NetBeans ${NB_VERSION} (verified SHA-512)"

nb_url="https://dlcdn.apache.org/netbeans/netbeans/${NB_VERSION}/netbeans-${NB_VERSION}-bin.zip"
nb_sha_url="https://downloads.apache.org/netbeans/netbeans/${NB_VERSION}/netbeans-${NB_VERSION}-bin.zip.sha512"
nb_zip="/tmp/netbeans-${NB_VERSION}-bin.zip"

download "${nb_url}" "${nb_zip}"
nb_sha="$(retry wget -qO- "${nb_sha_url}" | awk '{print $1}')"
verify_sha512 "${nb_zip}" "${nb_sha}"

rm -rf /opt/netbeans
unzip -q -d /opt "${nb_zip}"
rm -f "${nb_zip}"

[[ -x /opt/netbeans/bin/netbeans ]] || die "NetBeans did not extract to /opt/netbeans"
ln -sfn /opt/netbeans/bin/netbeans /usr/local/bin/netbeans
