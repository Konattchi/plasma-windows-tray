#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PATCH="$PROJECT_ROOT/patches/plasma-6.7-systemtray.patch"
EXPECTED_PATCH_SHA="b1afd650673b358e7f4e2b7b6981e3810b21468f67f17e0bdc21877aa7ab6efc"

echo "== Release checks =="

[[ -f "$PATCH" ]] || {
    echo "ERROR: missing patch: $PATCH"
    exit 1
}

ACTUAL_PATCH_SHA="$(sha256sum "$PATCH" | awk '{print $1}')"
[[ "$ACTUAL_PATCH_SHA" == "$EXPECTED_PATCH_SHA" ]] || {
    echo "ERROR: patch hash mismatch"
    echo "Expected: $EXPECTED_PATCH_SHA"
    echo "Actual:   $ACTUAL_PATCH_SHA"
    exit 1
}

echo "Patch hash: OK"

for script in "$PROJECT_ROOT"/scripts/*.sh; do
    bash -n "$script"
done
echo "Shell syntax: OK"

# Exclude this checker itself: it necessarily contains the strings it scans for.
for pat in '/home/konattchi' '/root/plasma-tray-backup' 'KNOWN-GOOD-STAGE' 'traymod-'; do
    if grep -RniF         --exclude-dir=.git         --exclude='check-release.sh'         "$pat" "$PROJECT_ROOT"; then
        echo "ERROR: private/development residue found for: $pat"
        exit 1
    fi
done
echo "Privacy/development residue scan: OK"

if grep -RniE     --exclude-dir=.git     --exclude='check-release.sh'     'TODO_PUBLIC|FIXME_PUBLIC|CHANGE_ME|YOUR_USERNAME'     "$PROJECT_ROOT"; then
    echo "ERROR: publication placeholder found"
    exit 1
fi
echo "Publication placeholder scan: OK"

echo
echo "Release checks passed."
