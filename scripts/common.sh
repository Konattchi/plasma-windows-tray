#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later

find_systemtray_plugin() {
    local candidate plugin_dir

    if command -v qtpaths6 >/dev/null 2>&1; then
        plugin_dir="$(qtpaths6 --plugin-dir 2>/dev/null || true)"
        candidate="$plugin_dir/plasma/applets/org.kde.plasma.systemtray.so"
        if [[ -f "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    fi

    if command -v qmake6 >/dev/null 2>&1; then
        plugin_dir="$(qmake6 -query QT_INSTALL_PLUGINS 2>/dev/null || true)"
        candidate="$plugin_dir/plasma/applets/org.kde.plasma.systemtray.so"
        if [[ -f "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    fi

    for candidate in         /usr/lib/qt6/plugins/plasma/applets/org.kde.plasma.systemtray.so         /usr/lib64/qt6/plugins/plasma/applets/org.kde.plasma.systemtray.so         /usr/lib/x86_64-linux-gnu/qt6/plugins/plasma/applets/org.kde.plasma.systemtray.so
    do
        if [[ -f "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    candidate="$(find /usr/lib /usr/lib64 -type f         -path '*/qt6/plugins/plasma/applets/org.kde.plasma.systemtray.so'         -print -quit 2>/dev/null || true)"

    if [[ -n "$candidate" ]]; then
        printf '%s\n' "$candidate"
        return 0
    fi

    return 1
}

installed_plasma_version() {
    if command -v plasmashell >/dev/null 2>&1; then
        plasmashell --version 2>/dev/null | awk '{print $NF}' | head -n1
    fi
}

plasma_series() {
    local v="${1:-}"
    if [[ "$v" =~ ^([0-9]+)\.([0-9]+) ]]; then
        printf '%s.%s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
    fi
}

sha256_file() {
    sha256sum "$1" | awk '{print $1}'
}

require_tool() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "ERROR: required tool not found: $1" >&2
        return 1
    }
}
