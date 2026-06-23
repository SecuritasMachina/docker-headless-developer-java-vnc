# shellcheck shell=bash
# desktop/vnc - TigerVNC server + noVNC HTML5 client and the runtime startup.

log "Installing TigerVNC + noVNC"
apt_install $(grep -vE '^\s*#|^\s*$' "${COMPONENT_DIR}/packages.lst")

# noVNC ships its web assets under /usr/share/novnc; expose a stable home and a
# vnc.html landing page (Ubuntu's package already provides vnc.html).
install -d -m 0755 "${NO_VNC_HOME:-/headless/noVNC}"
if [[ -d /usr/share/novnc ]]; then
  cp -r /usr/share/novnc/* "${NO_VNC_HOME:-/headless/noVNC}/" 2>/dev/null || true
fi
[[ -e "${NO_VNC_HOME:-/headless/noVNC}/index.html" ]] || \
  ln -sf "${NO_VNC_HOME:-/headless/noVNC}/vnc.html" "${NO_VNC_HOME:-/headless/noVNC}/index.html" 2>/dev/null || true

# Install the runtime VNC startup the generic entrypoint hands off to.
install -d -m 0755 /dockerstartup
install -m 0755 "${COMPONENT_DIR}/vnc_startup.sh" /dockerstartup/vnc_startup.sh
