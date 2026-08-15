#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/scripts/common.sh"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/plasma-windows-tray"
STATE_FILE="$STATE_DIR/state.env"

SYSTEM_PLUGIN="$(find_systemtray_plugin)" || {
    echo "ERROR: could not locate installed System Tray plugin."
    exit 1
}
CURRENT_SHA="$(sha256_file "$SYSTEM_PLUGIN")"

echo "System Tray plugin:"
echo "  $SYSTEM_PLUGIN"
echo "Current SHA-256:"
echo "  $CURRENT_SHA"

if [[ ! -f "$STATE_FILE" ]]; then
    echo
    echo "No installer state file exists yet."
    echo "State: UNKNOWN / unmanaged by this package"
    exit 0
fi

source "$STATE_FILE"

echo
echo "Recorded mod SHA-256:"
echo "  ${INSTALLED_MOD_SHA:-unknown}"
echo "Recorded backup SHA-256:"
echo "  ${BACKUP_SHA:-unknown}"

if [[ -n "${INSTALLED_MOD_SHA:-}" && "$CURRENT_SHA" == "$INSTALLED_MOD_SHA" ]]; then
    echo
    echo "State: MOD INSTALLED"
    exit 0
fi

if [[ -n "${BACKUP_SHA:-}" && "$CURRENT_SHA" == "$BACKUP_SHA" ]]; then
    echo
    echo "State: RESTORED BACKUP"
    exit 0
fi

echo
echo "State: UNKNOWN / plugin changed outside this package"
exit 1
