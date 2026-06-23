#!/usr/bin/env bash
#
# stackbuild/entrypoint.sh - generic runtime entrypoint for assembled stacks.
# ---------------------------------------------------------------------------
# Stack-agnostic: it provisions the per-user home, then hands off to the VNC
# startup script installed by the desktop/vnc component (if the stack includes
# a desktop). Stacks without a desktop just run the given command.
set -eo pipefail

help() {
cat <<'USAGE'
USAGE:
  docker run -it -p 6901:6901 -p 5901:5901 <image> <option>

OPTIONS:
  -w, --wait   (default) start the desktop/VNC and block until SIGINT/SIGTERM
  -s, --skip   skip VNC startup and exec the given command (e.g. --skip bash)
  -d, --debug  verbose startup
  -h, --help   show this help

Connect:
  VNC viewer  -> localhost:5901   (password printed at startup)
  noVNC HTML5 -> http://localhost:6901/vnc.html
USAGE
}

case "${1:-}" in
  -h|--help) help; exit 0 ;;
  -d|--debug) set -x; shift ;;
esac

CONTAINER_USER="${CONTAINER_USER:-superstar}"
HOME="${HOME:-/home/${CONTAINER_USER}}"

# Seed the user's home from the image skeleton on first run (idempotent).
if [[ -d /etc/skel && -d "${HOME}" ]]; then
  cp -rn /etc/skel/. "${HOME}/" 2>/dev/null || true
fi

# No desktop in this stack (or explicitly skipped) -> just run the command.
if [[ "${1:-}" == "-s" || "${1:-}" == "--skip" ]]; then
  shift
  exec "${@:-bash}"
fi

if [[ ! -x /dockerstartup/vnc_startup.sh ]]; then
  echo "No desktop/vnc component in this stack; exec'ing command."
  exec "${@:-bash}"
fi

exec /dockerstartup/vnc_startup.sh "${@:---wait}"
