#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/scripts/common.sh"

TESTED_SERIES="6.7"
PATCH="$PROJECT_ROOT/patches/plasma-6.7-systemtray.patch"
TOOLTIP_PATCH="$PROJECT_ROOT/patches/plasma-6.7-native-tooltips.patch"
REPO_URL="https://invent.kde.org/plasma/plasma-workspace.git"

WORK_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}/plasma-windows-tray"
SRC="$WORK_ROOT/plasma-workspace"
BUILD="$WORK_ROOT/build"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/plasma-windows-tray"
BACKUP="$STATE_DIR/org.kde.plasma.systemtray.so.backup"
STATE_FILE="$STATE_DIR/state.env"

DRY_RUN=0
FORCE_VERSION=0
BACKUP_FROM=""
BACKUP_FROM_NEEDS_SUDO=0

usage() {
    cat <<'USAGE'
Usage: install.sh [options]

Options:
  --dry-run              Check environment, version, plugin path, and patch files.
                         Does not build, install, or modify files.
  --force-version        Allow installation when installed Plasma is not 6.7.x.
  --backup-from PATH     On first install, seed the immutable restore backup from PATH
                         instead of the currently installed plugin.
  -h, --help             Show this help.

The restore backup is created once and is never overwritten automatically.
Temporary source/build files live under ~/.cache/plasma-windows-tray.
USAGE
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --force-version)
            FORCE_VERSION=1
            shift
            ;;
        --backup-from)
            [[ $# -ge 2 ]] || { echo "ERROR: --backup-from requires a path"; exit 2; }
            BACKUP_FROM="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "ERROR: unknown option: $1"
            usage
            exit 2
            ;;
    esac
done

for tool in git cmake ninja sha256sum ldd realpath; do
    require_tool "$tool"
done

[[ -f "$PATCH" ]] || { echo "ERROR: missing patch: $PATCH"; exit 1; }
[[ -f "$TOOLTIP_PATCH" ]] || { echo "ERROR: missing tooltip patch: $TOOLTIP_PATCH"; exit 1; }

SYSTEM_PLUGIN="$(find_systemtray_plugin)" || {
    echo "ERROR: could not locate org.kde.plasma.systemtray.so"
    exit 1
}

PLASMA_VERSION="$(installed_plasma_version || true)"
SERIES="$(plasma_series "$PLASMA_VERSION" || true)"
SOURCE_TAG="v${PLASMA_VERSION}"

echo "Detected System Tray plugin: $SYSTEM_PLUGIN"
echo "Installed Plasma version: ${PLASMA_VERSION:-unknown}"
echo "Tested Plasma series: $TESTED_SERIES"
echo "Plasma source tag: $SOURCE_TAG"
echo "System tray patch SHA-256: $(sha256_file "$PATCH")"
echo "Native tooltip patch SHA-256: $(sha256_file "$TOOLTIP_PATCH")"

if [[ -z "$PLASMA_VERSION" ]]; then
    echo "ERROR: could not determine installed Plasma version."
    exit 1
fi

if [[ "$SERIES" != "$TESTED_SERIES" && "$FORCE_VERSION" -ne 1 ]]; then
    echo "ERROR: installed Plasma series is '${SERIES:-unknown}', not '$TESTED_SERIES'."
    echo "Use --force-version only after verifying compatibility."
    exit 1
fi

if [[ -n "$BACKUP_FROM" ]]; then
    if [[ -f "$BACKUP_FROM" && -r "$BACKUP_FROM" ]]; then
        BACKUP_FROM="$(realpath "$BACKUP_FROM")"
    elif sudo test -f "$BACKUP_FROM"; then
        BACKUP_FROM="$(sudo realpath "$BACKUP_FROM")"
        BACKUP_FROM_NEEDS_SUDO=1
    else
        echo "ERROR: --backup-from file does not exist or cannot be accessed: $BACKUP_FROM"
        exit 1
    fi
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY RUN COMPLETE. No source checkout, build, backup, install, or Plasma restart was performed."
    exit 0
fi

mkdir -p "$WORK_ROOT" "$STATE_DIR"

# Always recreate the source tree. This avoids stale/shallow Git state from an
# earlier installation and guarantees that the exact installed Plasma tag is
# what gets patched and built.
rm -rf "$SRC" "$BUILD"

echo "Cloning Plasma Workspace $SOURCE_TAG..."
if ! git clone --depth 1 --branch "$SOURCE_TAG" "$REPO_URL" "$SRC"; then
    echo "ERROR: could not clone Plasma Workspace tag $SOURCE_TAG."
    echo "The installed Plasma version may not have a matching upstream tag yet."
    exit 1
fi

ACTUAL_TAG="$(git -C "$SRC" describe --tags --exact-match 2>/dev/null || true)"
if [[ "$ACTUAL_TAG" != "$SOURCE_TAG" ]]; then
    echo "ERROR: source checkout mismatch. Expected $SOURCE_TAG, got ${ACTUAL_TAG:-unknown}."
    exit 1
fi

echo "Checking and applying main System Tray patch..."
git -C "$SRC" apply --check "$PATCH"
git -C "$SRC" apply "$PATCH"

echo "Checking and applying native tooltip patch..."
git -C "$SRC" apply --check "$TOOLTIP_PATCH"
git -C "$SRC" apply "$TOOLTIP_PATCH"

echo "Configuring build..."
cmake -S "$SRC" -B "$BUILD" -G Ninja \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_INSTALL_PREFIX=/usr

echo "Building org.kde.plasma.systemtray..."
cmake --build "$BUILD" --target org.kde.plasma.systemtray

PLUGIN="$BUILD/bin/plasma/applets/org.kde.plasma.systemtray.so"
[[ -f "$PLUGIN" ]] || {
    echo "ERROR: built plugin missing: $PLUGIN"
    exit 1
}

if ldd "$PLUGIN" | grep -q 'not found'; then
    echo "ERROR: unresolved plugin dependencies:"
    ldd "$PLUGIN" | grep 'not found'
    exit 1
fi

if [[ ! -f "$BACKUP" ]]; then
    echo "Creating immutable restore backup..."
    if [[ -n "$BACKUP_FROM" ]]; then
        if [[ "$BACKUP_FROM_NEEDS_SUDO" -eq 1 ]]; then
            TMP_BACKUP="$STATE_DIR/.stock-backup.tmp"
            sudo cp -a "$BACKUP_FROM" "$TMP_BACKUP"
            sudo chown "$(id -u):$(id -g)" "$TMP_BACKUP"
            mv "$TMP_BACKUP" "$BACKUP"
        else
            cp -a "$BACKUP_FROM" "$BACKUP"
        fi
    else
        cp -a "$SYSTEM_PLUGIN" "$BACKUP"
    fi
fi

BACKUP_SHA="$(sha256_file "$BACKUP")"
BUILT_SHA="$(sha256_file "$PLUGIN")"
BEFORE_SHA="$(sha256_file "$SYSTEM_PLUGIN")"

sudo cp "$PLUGIN" "$SYSTEM_PLUGIN"
AFTER_SHA="$(sha256_file "$SYSTEM_PLUGIN")"

[[ "$AFTER_SHA" == "$BUILT_SHA" ]] || {
    echo "ERROR: installed plugin hash does not match built plugin."
    exit 1
}

cat > "$STATE_FILE" <<STATE
SYSTEM_PLUGIN='$SYSTEM_PLUGIN'
BACKUP='$BACKUP'
BACKUP_SHA='$BACKUP_SHA'
SYSTEMTRAY_PATCH_SHA='$(sha256_file "$PATCH")'
TOOLTIP_PATCH_SHA='$(sha256_file "$TOOLTIP_PATCH")'
SOURCE_TAG='$SOURCE_TAG'
PLASMA_VERSION='$PLASMA_VERSION'
BEFORE_INSTALL_SHA='$BEFORE_SHA'
INSTALLED_MOD_SHA='$AFTER_SHA'
STATE

systemctl --user restart plasma-plasmashell.service

echo
echo "Installation complete."
echo "Installed mod SHA-256: $AFTER_SHA"
echo "Immutable restore backup: $BACKUP"
echo "Run scripts/verify.sh to verify the current state."
