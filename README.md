# Plasma Windows-Style System Tray Mod

A KDE Plasma System Tray modification that adds a Windows-style tray overflow workflow while preserving normal Plasma applet behavior.

## Project status

**Release:** 1.0.0  
**Released target:** KDE Plasma 6.7.x; **Plasma 6.8.0 port:** validated on `plasma-6.8-port` branch  
**Tested:** KDE Plasma 6.7.4 and 6.8.0 (CachyOS)

The installer has been tested end-to-end on Plasma 6.7.4 and Plasma 6.8.0: source checkout, patching, compilation, installation, and verification. On Plasma 6.8.0, restore to the stock plugin and reinstallation were also tested successfully.

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

## Quick install — Plasma 6.7.x / 6.8.0 testing branch

Copy and paste this into a terminal:

```bash
git clone https://github.com/Konattchi/plasma-windows-tray.git
cd plasma-windows-tray
./scripts/install.sh --dry-run
# First managed installation requires a verified stock System Tray plugin backup:
./scripts/install.sh --backup-from /path/to/verified-stock/org.kde.plasma.systemtray.so
./scripts/verify.sh
```

A successful verification ends with:

```text
State: MOD INSTALLED
```

The installer will ask for `sudo` only when it needs to replace the system System Tray plugin. Source and build files are kept outside the repository under `~/.cache/plasma-windows-tray`, while persistent restore state is stored under `~/.local/state/plasma-windows-tray`.

### Already running a manually installed copy?

If this mod was previously installed manually, do **not** let the installer mistake the modified plugin for the original stock plugin. A verified stock System Tray plugin backup is required on the first managed installation, even if the mod is not currently installed. Use a backup from the exact installed Plasma version:

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

The installer selects the 6.7 patches for Plasma 6.7.x and the combined patch for exactly Plasma 6.8.0. Other versions are not supported by the current patch selector, including when `--force-version` is supplied.

On first managed installation it seeds an immutable restore backup from the explicitly supplied stock plugin and does not overwrite that backup automatically. Backups from earlier Plasma versions must be archived before starting a new managed installation.

## Restore stock Plasma tray

```bash
./scripts/restore.sh
./scripts/verify.sh
```

## Plasma updates / reapply the mod

A Plasma package update can replace the modified System Tray plugin with KDE's stock copy. Your tray ordering is stored by Plasma separately, so reapplying the mod does not normally require arranging the icons again.

For an existing managed installation, update this repository and run:

```bash
git pull
./scripts/reapply.sh --dry-run
./scripts/reapply.sh
```

`reapply.sh` requires the existing managed installation state and immutable restore backup. It deliberately refuses to create a new backup from the post-update plugin, so the original stock restore copy remains protected. It then uses the normal installer to rebuild against the detected Plasma version and runs `verify.sh` automatically.

If the dry run reports a version other than 6.7.x or exactly 6.8.0, do not attempt installation until a compatible patch is available.

For developers, the repository also includes a compatibility-only build helper:

```bash
./scripts/rebuild-after-plasma-update.sh /path/to/plasma-workspace
```

That helper performs a compatibility build but does not automatically install the result.

## Repository contents

- `patches/plasma-6.7-systemtray.patch` — Windows-style tray behavior and overflow UI.
- `patches/plasma-6.7-native-tooltips.patch` — native Plasma tooltip behavior for the popup header controls.
- `patches/plasma-6.8-systemtray.patch` — combined System Tray and native tooltip changes for Plasma 6.8.0.
- `scripts/install.sh` — checks, downloads matching Plasma source, patches, builds, backs up, installs, and restarts Plasma.
- `scripts/reapply.sh` — safely rebuilds and reapplies an existing managed installation after Plasma updates.
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
