# shellcheck shell=bash
# servers/tomcat - Apache Tomcat 9 servlet container, verified by the official
# SHA-512 checksum AND a detached GPG signature against the Apache KEYS file.

TOMCAT_VERSION="${TOMCAT_VERSION:-9.0.119}"

archive="apache-tomcat-${TOMCAT_VERSION}.tar.gz"
base_url="https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin"
tarball="/tmp/${archive}"
asc="/tmp/${archive}.asc"
sha512="/tmp/${archive}.sha512"

log "Downloading Apache Tomcat ${TOMCAT_VERSION}"
download "${base_url}/${archive}" "${tarball}"
download "${base_url}/${archive}.asc" "${asc}"
download "${base_url}/${archive}.sha512" "${sha512}"

log "Verifying Tomcat ${TOMCAT_VERSION} SHA-512 (official .sha512)"
# The Apache .sha512 file lists "<hex>  <filename>"; extract just the hex digest.
tomcat_sha="$(awk '{print $1; exit}' "${sha512}")"
verify_sha512 "${tarball}" "${tomcat_sha}"

log "Verifying Tomcat ${TOMCAT_VERSION} GPG signature (Apache KEYS)"
gpg_verify "${asc}" "${tarball}" "https://downloads.apache.org/tomcat/tomcat-9/KEYS"

log "Installing Tomcat ${TOMCAT_VERSION} to /opt/tomcat"
install -d /opt/tomcat
tar -xzf "${tarball}" -C /opt/tomcat
ln -sfn "/opt/tomcat/apache-tomcat-${TOMCAT_VERSION}" /opt/tomcat/latest
rm -f "${tarball}" "${asc}" "${sha512}"

cat > /etc/profile.d/tomcat.sh <<'PROFILE'
export CATALINA_HOME=/opt/tomcat/latest
export PATH="${CATALINA_HOME}/bin:${PATH}"
PROFILE
