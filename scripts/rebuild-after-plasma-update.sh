#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/scripts/common.sh"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 /path/to/plasma-workspace"
    exit 2
fi

SRC="$(realpath "$1")"
SOURCE_TAG="$(git -C "$SRC" describe --tags --exact-match 2>/dev/null || true)"
case "$SOURCE_TAG" in
    v6.7.*)
        PATCH="$PROJECT_ROOT/patches/plasma-6.7-systemtray.patch"
        TOOLTIP_PATCH="$PROJECT_ROOT/patches/plasma-6.7-native-tooltips.patch"
        ;;
    v6.8.0)
        PATCH="$PROJECT_ROOT/patches/plasma-6.8-systemtray.patch"
        TOOLTIP_PATCH=""
        ;;
    *)
        echo "ERROR: unsupported source tag: ${SOURCE_TAG:-none}; use a pristine supported tag."
        exit 1
        ;;
esac
BUILD="${XDG_CACHE_HOME:-$HOME/.cache}/plasma-windows-tray/update-build"

[[ -d "$SRC/.git" ]] || {
    echo "ERROR: not a git Plasma Workspace source tree: $SRC"
    exit 1
}

[[ -f "$PATCH" ]] || { echo "ERROR: missing patch: $PATCH"; exit 1; }
if [[ -n "$TOOLTIP_PATCH" ]]; then
    [[ -f "$TOOLTIP_PATCH" ]] || { echo "ERROR: missing patch: $TOOLTIP_PATCH"; exit 1; }
fi

for tool in git cmake ninja ldd; do
    require_tool "$tool"
done

echo "Testing patches against:"
git -C "$SRC" rev-parse --short HEAD

git -C "$SRC" apply --check "$PATCH"

TMP="${XDG_CACHE_HOME:-$HOME/.cache}/plasma-windows-tray/update-source"
rm -rf "$TMP" "$BUILD"
git clone --no-local "$SRC" "$TMP"
git -C "$TMP" apply "$PATCH"
if [[ -n "$TOOLTIP_PATCH" ]]; then
    git -C "$TMP" apply --check "$TOOLTIP_PATCH"
    git -C "$TMP" apply "$TOOLTIP_PATCH"
fi

cmake -S "$TMP" -B "$BUILD" -G Ninja \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_INSTALL_PREFIX=/usr

cmake --build "$BUILD" --target org.kde.plasma.systemtray

PLUGIN="$BUILD/bin/plasma/applets/org.kde.plasma.systemtray.so"
[[ -f "$PLUGIN" ]] || {
    echo "ERROR: built plugin missing."
    exit 1
}

if ldd "$PLUGIN" | grep -q 'not found'; then
    echo "ERROR: unresolved plugin dependencies:"
    ldd "$PLUGIN" | grep 'not found'
    exit 1
fi

echo
echo "Compatibility build succeeded with selected patch(es)."
echo "No system files were installed."
