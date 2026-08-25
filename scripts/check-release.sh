#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MAIN_PATCH="$PROJECT_ROOT/patches/plasma-6.7-systemtray.patch"
TOOLTIP_PATCH="$PROJECT_ROOT/patches/plasma-6.7-native-tooltips.patch"
EXPECTED_MAIN_PATCH_SHA="b1afd650673b358e7f4e2b7b6981e3810b21468f67f17e0bdc21877aa7ab6efc"
EXPECTED_TOOLTIP_PATCH_SHA="b3b0768e82cd523450df92b3bbf9eb19c4cf91559ee596e12bab6f6dbb1cea3f"

echo "== Release checks =="

check_hash() {
    local label="$1"
    local file="$2"
    local expected="$3"

    [[ -f "$file" ]] || {
        echo "ERROR: missing $label: $file"
        exit 1
    }

    local actual
    actual="$(sha256sum "$file" | awk '{print $1}')"
    [[ "$actual" == "$expected" ]] || {
        echo "ERROR: $label hash mismatch"
        echo "Expected: $expected"
        echo "Actual:   $actual"
        exit 1
    }

    echo "$label hash: OK"
}

check_hash "System tray patch" "$MAIN_PATCH" "$EXPECTED_MAIN_PATCH_SHA"
check_hash "Native tooltip patch" "$TOOLTIP_PATCH" "$EXPECTED_TOOLTIP_PATCH_SHA"

for script in "$PROJECT_ROOT"/scripts/*.sh; do
    bash -n "$script"
done
echo "Shell syntax: OK"

for script in \
    "$PROJECT_ROOT/scripts/install.sh" \
    "$PROJECT_ROOT/scripts/restore.sh" \
    "$PROJECT_ROOT/scripts/verify.sh" \
    "$PROJECT_ROOT/scripts/check-release.sh" \
    "$PROJECT_ROOT/scripts/reapply.sh" \
    "$PROJECT_ROOT/scripts/rebuild-after-plasma-update.sh"; do
    [[ -x "$script" ]] || {
        echo "ERROR: script is not executable: $script"
        exit 1
    }
done
echo "Script executable modes: OK"

# Exclude this checker itself: it necessarily contains the strings it scans for.
for pat in '/home/konattchi' '/root/plasma-tray-backup' 'KNOWN-GOOD-STAGE' 'traymod-'; do
    if grep -RniF \
        --exclude-dir=.git \
        --exclude='check-release.sh' \
        "$pat" "$PROJECT_ROOT"; then
        echo "ERROR: private/development residue found for: $pat"
        exit 1
    fi
done
echo "Privacy/development residue scan: OK"

if grep -RniE \
    --exclude-dir=.git \
    --exclude='check-release.sh' \
    'TODO_PUBLIC|FIXME_PUBLIC|CHANGE_ME|YOUR_USERNAME' \
    "$PROJECT_ROOT"; then
    echo "ERROR: publication placeholder found"
    exit 1
fi
echo "Publication placeholder scan: OK"

echo
echo "Release checks passed."
