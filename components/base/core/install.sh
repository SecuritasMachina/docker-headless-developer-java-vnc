# shellcheck shell=bash
# base/core - foundational layer every stack builds on.
# Sourced by run-component.sh with helpers.sh already loaded.

CONTAINER_USER="${CONTAINER_USER:-superstar}"
CONTAINER_UID="${CONTAINER_UID:-1500}"

log "Updating base system and installing core tools"
retry apt-get update
retry apt-get -y upgrade
apt_install $(grep -vE '^\s*#|^\s*$' "${COMPONENT_DIR}/packages.lst")

log "Generating en_US.UTF-8 locale"
locale-gen en_US.UTF-8
update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

log "Creating non-root container user '${CONTAINER_USER}' (uid ${CONTAINER_UID})"
if ! getent group "${CONTAINER_USER}" >/dev/null; then
  groupadd -g "${CONTAINER_UID}" "${CONTAINER_USER}"
fi
if ! id "${CONTAINER_USER}" >/dev/null 2>&1; then
  useradd -m -u "${CONTAINER_UID}" -g "${CONTAINER_USER}" -G sudo -s /bin/bash "${CONTAINER_USER}"
fi

# Generate a policy-satisfying random sudo password (printed to the build log
# only, mirroring the original image's model) rather than leaving it unset.
USER_PASSWORD="$(tr -dc 'A-Za-z0-9#%^' </dev/urandom | head -c 32 || true)A1#"
echo "${CONTAINER_USER}:${USER_PASSWORD}" | chpasswd
log "Created ${CONTAINER_USER} sudo password (build-log only): ${USER_PASSWORD}"

# Skeleton home + Desktop that desktop components and the entrypoint populate.
install -d -m 0755 /etc/skel/Desktop
install -d -m 0755 "/home/${CONTAINER_USER}/Desktop"
chown -R "${CONTAINER_USER}:${CONTAINER_USER}" "/home/${CONTAINER_USER}"
