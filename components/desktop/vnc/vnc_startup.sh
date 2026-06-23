#!/usr/bin/env bash
#
# /dockerstartup/vnc_startup.sh - bring up TigerVNC + the Xfce session + noVNC.
# Invoked by stackbuild/entrypoint.sh for stacks that include desktop/vnc.
set -eo pipefail

CONTAINER_USER="${CONTAINER_USER:-superstar}"
HOME="${HOME:-/home/${CONTAINER_USER}}"
VNC_PORT="${VNC_PORT:-5901}"
NO_VNC_PORT="${NO_VNC_PORT:-6901}"
NO_VNC_HOME="${NO_VNC_HOME:-/headless/noVNC}"
VNC_RESOLUTION="${VNC_RESOLUTION:-1280x1024}"
VNC_COL_DEPTH="${VNC_COL_DEPTH:-24}"
DISPLAY="${DISPLAY:-:1}"
VNC_DISPLAY_NUM="${DISPLAY#:}"

mkdir -p "${HOME}/.vnc"

# Password: use $VNC_PW if provided, else generate a random one and print it.
if [[ -z "${VNC_PW:-}" ]]; then
  VNC_PW="$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 10 || echo vncpass01)"
  echo "=== Generated VNC password: ${VNC_PW} ==="
fi
printf '%s\n%s\n\n' "${VNC_PW}" "${VNC_PW}" | vncpasswd -f > "${HOME}/.vnc/passwd"
chmod 600 "${HOME}/.vnc/passwd"

# Xfce session as the VNC desktop.
cat > "${HOME}/.vnc/xstartup" <<'XSTARTUP'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XDG_CURRENT_DESKTOP=XFCE
exec dbus-launch --exit-with-session startxfce4
XSTARTUP
chmod 755 "${HOME}/.vnc/xstartup"

# Clean any stale lock from a previous run, then start the server.
vncserver -kill "${DISPLAY}" >/dev/null 2>&1 || true
rm -f "/tmp/.X${VNC_DISPLAY_NUM}-lock" "/tmp/.X11-unix/X${VNC_DISPLAY_NUM}" 2>/dev/null || true

echo "=== Starting TigerVNC on ${DISPLAY} (${VNC_RESOLUTION}x${VNC_COL_DEPTH}) ==="
vncserver "${DISPLAY}" -geometry "${VNC_RESOLUTION}" -depth "${VNC_COL_DEPTH}" -localhost no

echo "=== Starting noVNC on :${NO_VNC_PORT} -> localhost:${VNC_PORT} ==="
WEBSOCKIFY="$(command -v websockify || echo /usr/bin/websockify)"
"${WEBSOCKIFY}" --web "${NO_VNC_HOME}" "${NO_VNC_PORT}" "localhost:${VNC_PORT}" >/var/log/novnc.log 2>&1 &

cat <<EOF

=========================================================================
  Desktop is up.
  VNC viewer  : localhost:${VNC_PORT}
  noVNC HTML5 : http://localhost:${NO_VNC_PORT}/vnc.html
=========================================================================
EOF

if [[ "${1:-}" == "-s" || "${1:-}" == "--skip" ]]; then
  shift; exec "${@:-bash}"
fi

# Block on the VNC server log so the container stays alive.
touch "${HOME}/.vnc/${HOSTNAME:-localhost}${DISPLAY}.log" 2>/dev/null || true
exec tail -f "${HOME}/.vnc/"*"${DISPLAY}.log" /dev/null
