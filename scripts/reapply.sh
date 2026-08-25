#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/plasma-windows-tray"
STATE_FILE="$STATE_DIR/state.env"
INSTALLER="$PROJECT_ROOT/scripts/install.sh"
VERIFY="$PROJECT_ROOT/scripts/verify.sh"

usage() {
    cat <<'USAGE'
Usage: reapply.sh [--dry-run]

Rebuild and reinstall the mod after a Plasma package update has replaced the
patched System Tray plugin.

Options:
  --dry-run   Run only the installer's compatibility/safety checks.
  -h, --help  Show this help.

This command requires an existing managed installation and restore backup.
It will never create a new stock backup from the currently installed plugin.
USAGE
}

DRY_RUN=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "ERROR: unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

[[ -x "$INSTALLER" ]] || {
    echo "ERROR: installer is missing or not executable: $INSTALLER" >&2
    exit 1
}

[[ -f "$STATE_FILE" ]] || {
    echo "ERROR: no managed installation state was found." >&2
    echo "Use ./scripts/install.sh for the first installation." >&2
    exit 1
}

# shellcheck disable=SC1090
source "$STATE_FILE"

[[ -n "${BACKUP:-}" && -f "$BACKUP" ]] || {
    echo "ERROR: the managed restore backup is missing." >&2
    echo "Refusing to reapply because the original stock backup must be preserved." >&2
    exit 1
}

if [[ "$DRY_RUN" -eq 1 ]]; then
    exec "$INSTALLER" --dry-run
fi

echo "Reapplying Plasma Windows-Style System Tray Mod..."
echo "Existing restore backup will be preserved:"
echo "  $BACKUP"
echo

"$INSTALLER"

echo
"$VERIFY"
