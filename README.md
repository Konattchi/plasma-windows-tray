# Plasma Windows-Style System Tray Mod

A KDE Plasma System Tray modification that adds a Windows-style tray overflow workflow while preserving normal Plasma applet behavior.

## Project status

**Release:** 1.0.0  
**Target:** KDE Plasma 6.7.x  
**Tested:** KDE Plasma 6.7.4

The installer has been tested end-to-end on Plasma 6.7.4: clean upstream source checkout, patching, compilation, installation, Plasma restart, and verification.

This is an unofficial patch, not an upstream KDE feature. Plasma internals can change between releases, so compatibility with newer Plasma versions is not guaranteed.

## What it does

The normal Plasma System Tray popup keeps its built-in Plasma controls at the top and adds a compact application-icon overflow area underneath. Application tray icons can be moved between the panel and overflow area in a workflow similar to Windows.

- Drag application tray icons from the panel into the overflow popup.
- Drag hidden application icons back onto the panel.
- Reorder visible tray icons.
- Reorder icons inside the overflow area.
- Preserve the original Plasma controls in the popup.
- Automatically grow the compact overflow area as additional rows are needed.
- Persist tray ordering across Plasma restarts.
- Preserve normal clicks, activation, context menus, and applet behavior.
- Use Plasma's native theme-aware tooltips for the popup header controls.

## Quick install — Plasma 6.7.x

Copy and paste this into a terminal:

```bash
git clone https://github.com/Konattchi/plasma-windows-tray.git
cd plasma-windows-tray
./scripts/install.sh --dry-run
./scripts/install.sh
./scripts/verify.sh
```

A successful verification ends with:

```text
State: MOD INSTALLED
```

The installer will ask for `sudo` only when it needs to replace the system System Tray plugin. Source and build files are kept outside the repository under `~/.cache/plasma-windows-tray`, while persistent restore state is stored under `~/.local/state/plasma-windows-tray`.

### Already running a manually installed copy?

If this mod was previously installed manually, do **not** let the installer mistake the modified plugin for the original stock plugin. If you have a known-good stock System Tray plugin backup, seed it explicitly on the first managed installation:

```bash
./scripts/install.sh --backup-from /path/to/stock/org.kde.plasma.systemtray.so
```

## Safety checks

The dry run is non-destructive:

```bash
./scripts/install.sh --dry-run
```

You can also run the repository release checks:

```bash
./scripts/check-release.sh
```

The installer refuses automatic installation when the detected Plasma series is not 6.7.x unless `--force-version` is explicitly supplied.

On first managed installation it creates an immutable restore backup and does not overwrite that backup automatically.

## Restore stock Plasma tray

```bash
./scripts/restore.sh
./scripts/verify.sh
```

## Plasma updates

A Plasma package update can replace the modified System Tray plugin. The repository includes a compatibility helper for testing the patches against another Plasma Workspace source tree:

```bash
./scripts/rebuild-after-plasma-update.sh /path/to/plasma-workspace
```

The helper performs a compatibility build but does not automatically install the result.

## Repository contents

- `patches/plasma-6.7-systemtray.patch` — Windows-style tray behavior and overflow UI.
- `patches/plasma-6.7-native-tooltips.patch` — native Plasma tooltip behavior for the popup header controls.
- `scripts/install.sh` — checks, downloads matching Plasma source, patches, builds, backs up, installs, and restarts Plasma.
- `scripts/verify.sh` — verifies whether the installed plugin matches the managed mod or backup.
- `scripts/restore.sh` — restores the System Tray plugin backup created by the installer.
- `scripts/rebuild-after-plasma-update.sh` — compatibility build helper.
- `docs/COMPATIBILITY.md` — compatibility notes.
- `docs/DEVELOPMENT-NOTES.md` — implementation notes.
- `docs/LICENSE-AUDIT.md` — SPDX audit of modified upstream files.

## Important

This is an unofficial modification of KDE Plasma Workspace. It is not an official KDE product, supported KDE configuration, or endorsed by KDE.

The patch modifies upstream KDE files and retains their existing SPDX license headers. See `docs/LICENSE-AUDIT.md`.

## Licensing

Original scripts and documentation created for this project are licensed under `GPL-2.0-or-later` unless stated otherwise.

The included patches modify KDE Plasma Workspace files. Those files retain their respective upstream `GPL-2.0-or-later` or `LGPL-2.0-or-later` licensing terms and copyright notices. See `LICENSE` and `docs/LICENSE-AUDIT.md` for details.

---

P.S.
Yes I understand no coding whatsoever.
And Yes I made all of this using AI. But hey it works! I really missed that from Windows and now I got it back!
Truth be told I have no idea how GitHub works and I hope people can contribute to this and update it if I am not around without having to
remix it or something like that. Again I have no idea how GitHub works...
