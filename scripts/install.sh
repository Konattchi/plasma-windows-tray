#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/scripts/common.sh"

TESTED_SERIES="6.7"
PATCH="$PROJECT_ROOT/patches/plasma-6.7-systemtray.patch"
TOOLTIP_PATCH="$PROJECT_ROOT/patches/plasma-6.7-native-tooltips.patch"
REPO_URL="https://invent.kde.org/plasma/plasma-workspace.git"