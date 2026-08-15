#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/scripts/common.sh"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/plasma-windows-tray"
STATE_FILE="$STATE_DIR/state.env"

[[ -f "$STATE_FILE" ]] || {
    echo "ERROR: state file not found: $STATE_FILE"
    echo "Restore cannot safely determine the expected backup."
    exit 1
}

source "$STATE_FILE"

[[ -n "${SYSTEM_PLUGIN:-}" && -n "${BACKUP:-}" && -n "${BACKUP_SHA:-}" ]] || {
    echo "ERROR: state file is incomplete."
    exit 1
}

[[ -f "$BACKUP" ]] || {
    echo "ERROR: backup not found: $BACKUP"
    exit 1
}

ACTUAL_BACKUP_SHA="$(sha256_file "$BACKUP")"
[[ "$ACTUAL_BACKUP_SHA" == "$BACKUP_SHA" ]] || {
    echo "ERROR: restore backup hash mismatch."
    echo "Expected: $BACKUP_SHA"
    echo "Actual:   $ACTUAL_BACKUP_SHA"
    exit 1
}

CURRENT_PLUGIN="$(find_systemtray_plugin)" || {
    echo "ERROR: could not locate installed System Tray plugin."
    exit 1
}

[[ "$CURRENT_PLUGIN" == "$SYSTEM_PLUGIN" ]] || {
    echo "ERROR: System Tray plugin path changed since installation."
    echo "Recorded: $SYSTEM_PLUGIN"
    echo "Current:  $CURRENT_PLUGIN"
    echo "Refusing automatic restore."
    exit 1
}

sudo cp "$BACKUP" "$SYSTEM_PLUGIN"

RESTORED_SHA="$(sha256_file "$SYSTEM_PLUGIN")"
[[ "$RESTORED_SHA" == "$BACKUP_SHA" ]] || {
    echo "ERROR: restored plugin hash mismatch."
    exit 1
}

systemctl --user restart plasma-plasmashell.service

echo
echo "Restore complete."
echo "Current plugin matches immutable backup:"
echo "  $RESTORED_SHA"
