# shellcheck shell=bash
# languages/java - OpenJDK 17 + 21 (LTS), Maven, and a verified Gradle binary.

GRADLE_VERSION="${GRADLE_VERSION:-8.14}"

log "Installing OpenJDK 17 + 21 and Maven (apt, signed repo)"
apt_install openjdk-17-jdk openjdk-21-jdk maven

# Default the JDK to 17 for broad compatibility.
if command -v update-java-alternatives >/dev/null 2>&1; then
  jdk17="$(update-java-alternatives -l 2>/dev/null | awk '/java-1.17|java-17/{print $1; exit}')"
  [[ -n "${jdk17}" ]] && update-java-alternatives -s "${jdk17}" 2>/dev/null || true
fi

log "Installing Gradle ${GRADLE_VERSION} (verified SHA-256)"
gradle_zip="/tmp/gradle-${GRADLE_VERSION}-bin.zip"
download "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" "${gradle_zip}"
# Gradle publishes the official checksum next to the artifact over HTTPS.
gradle_sha="$(retry wget -qO- "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip.sha256")"
verify_sha256 "${gradle_zip}" "${gradle_sha}"

install -d /opt/gradle
unzip -q -d /opt/gradle "${gradle_zip}"
ln -sfn "/opt/gradle/gradle-${GRADLE_VERSION}" /opt/gradle/latest
rm -f "${gradle_zip}"

cat > /etc/profile.d/gradle.sh <<'PROFILE'
export GRADLE_HOME=/opt/gradle/latest
export PATH="${GRADLE_HOME}/bin:${PATH}"
PROFILE
ln -sf /opt/gradle/latest/bin/gradle /usr/local/bin/gradle
