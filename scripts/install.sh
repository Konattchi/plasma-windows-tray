#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/scripts/common.sh"

BASE_COMMIT="668b662b8baafd18d9a544b58d1ccc359c04cb8e"
TESTED_SERIES="6.7"
PATCH="$PROJECT_ROOT/patches/plasma-6.7-systemtray.patch"
PATCH_SHA="b1afd650673b358e7f4e2b7b6981e3810b21468f67f17e0bdc21877aa7ab6efc"
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
  --dry-run              Check environment, version, plugin path, and patch metadata.
                         Does not build, install, or modify files.
  --force-version        Allow installation when installed Plasma is not 6.7.x.
  --backup-from PATH     On first install, seed the immutable restore backup from PATH
                         instead of the currently installed plugin.
  -h, --help             Show this help.

The restore backup is created once and is never overwritten automatically.
USAGE
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=1; shift ;;
        --force-version) FORCE_VERSION=1; shift ;;
        --backup-from)
            [[ $# -ge 2 ]] || { echo "ERROR: --backup-from requires a path"; exit 2; }
            BACKUP_FROM="$2"
            shift 2
            ;;
        -h|--help) usage; exit 0 ;;
        *) echo "ERROR: unknown option: $1"; usage; exit 2 ;;
    esac
done

for tool in git cmake ninja sha256sum ldd; do
    require_tool "$tool"
done

SYSTEM_PLUGIN="$(find_systemtray_plugin)" || {
    echo "ERROR: could not locate org.kde.plasma.systemtray.so"
    exit 1
}

PLASMA_VERSION="$(installed_plasma_version || true)"
SERIES="$(plasma_series "$PLASMA_VERSION" || true)"

echo "Detected System Tray plugin:"
echo "  $SYSTEM_PLUGIN"
echo "Installed Plasma version:"
echo "  ${PLASMA_VERSION:-unknown}"
echo "Tested Plasma series:"
echo "  $TESTED_SERIES"
echo "Patch SHA-256:"
echo "  $PATCH_SHA"
echo "Tested source commit:"
echo "  $BASE_COMMIT"

if [[ "$SERIES" != "$TESTED_SERIES" && "$FORCE_VERSION" -ne 1 ]]; then
    echo
    echo "ERROR: installed Plasma series is '${SERIES:-unknown}', not '$TESTED_SERIES'."
    echo "Refusing automatic installation."
    echo "Use --force-version only after verifying compatibility."
    exit 1
fi

CURRENT_PATCH_SHA="$(sha256_file "$PATCH")"
[[ "$CURRENT_PATCH_SHA" == "$PATCH_SHA" ]] || {
    echo "ERROR: packaged patch hash does not match release metadata."
    exit 1
}

if [[ -n "$BACKUP_FROM" ]]; then
    if [[ -f "$BACKUP_FROM" && -r "$BACKUP_FROM" ]]; then
        BACKUP_FROM="$(realpath "$BACKUP_FROM")"
        BACKUP_FROM_NEEDS_SUDO=0
    elif sudo test -f "$BACKUP_FROM"; then
        BACKUP_FROM="$(sudo realpath "$BACKUP_FROM")"
        BACKUP_FROM_NEEDS_SUDO=1
    else
        echo "ERROR: --backup-from file does not exist or cannot be accessed: $BACKUP_FROM"
        exit 1
    fi
fi

echo
echo "Current installed plugin SHA-256:"
echo "  $(sha256_file "$SYSTEM_PLUGIN")"

if [[ -f "$BACKUP" ]]; then
    echo "Existing immutable restore backup:"
    echo "  $BACKUP"
    echo "  SHA-256: $(sha256_file "$BACKUP")"
elif [[ -n "$BACKUP_FROM" ]]; then
    echo "First-install backup will be seeded from:"
    echo "  $BACKUP_FROM"
    if [[ "$BACKUP_FROM_NEEDS_SUDO" -eq 1 ]]; then
        echo "  SHA-256: $(sudo sha256sum "$BACKUP_FROM" | awk '{print $1}')"
    else
        echo "  SHA-256: $(sha256_file "$BACKUP_FROM")"
    fi
else
    echo "No restore backup exists yet."
    echo "First install would back up the currently installed plugin."
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
    echo
    echo "DRY RUN COMPLETE."
    echo "No source checkout, build, backup, install, or Plasma restart was performed."
    exit 0
fi

mkdir -p "$WORK_ROOT" "$STATE_DIR"

if [[ ! -d "$SRC/.git" ]]; then
    git clone "$REPO_URL" "$SRC"
fi

git -C "$SRC" fetch --all --tags
git -C "$SRC" reset --hard
git -C "$SRC" clean -fdx
git -C "$SRC" checkout "$BASE_COMMIT"

git -C "$SRC" apply --check "$PATCH"
git -C "$SRC" apply "$PATCH"

rm -rf "$BUILD"
cmake -S "$SRC" -B "$BUILD" -G Ninja     -DCMAKE_BUILD_TYPE=RelWithDebInfo     -DCMAKE_INSTALL_PREFIX=/usr

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
PATCH_SHA='$PATCH_SHA'
BASE_COMMIT='$BASE_COMMIT'
PLASMA_VERSION='$PLASMA_VERSION'
BEFORE_INSTALL_SHA='$BEFORE_SHA'
INSTALLED_MOD_SHA='$AFTER_SHA'
STATE

systemctl --user restart plasma-plasmashell.service

echo
echo "Installation complete."
echo "Installed mod SHA-256:"
echo "  $AFTER_SHA"
echo "Immutable restore backup:"
echo "  $BACKUP"
echo "  $BACKUP_SHA"
echo
echo "Run scripts/verify.sh to verify the current state."
