#!/usr/bin/env bash
#
# stackbuild/run-component.sh <component-id>
# ------------------------------------------
# Thin wrapper invoked once per component from the generated Dockerfile. It
# sources the shared helpers, runs the component's install.sh, then wires in any
# desktop launchers the component ships. Keeping this logic here (rather than in
# every install.sh) is what lets a component be a tiny, single-purpose script.

set -euo pipefail

STACKBUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPONENTS_DIR="${COMPONENTS_DIR:-/stackbuild/components}"

component_id="${1:?usage: run-component.sh <component-id>}"
component_dir="${COMPONENTS_DIR}/${component_id}"

[[ -d "${component_dir}" ]]            || { echo "ERROR: no such component: ${component_id}" >&2; exit 1; }
[[ -f "${component_dir}/install.sh" ]] || { echo "ERROR: component ${component_id} has no install.sh" >&2; exit 1; }

# shellcheck source=/dev/null
source "${STACKBUILD_DIR}/helpers.sh"

log "Installing component: ${component_id}"
export COMPONENT_DIR="${component_dir}"
# shellcheck source=/dev/null
source "${component_dir}/install.sh"

install_desktop_launchers "${component_dir}"

log "Component complete: ${component_id}"
