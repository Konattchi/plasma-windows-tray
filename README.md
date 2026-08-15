# Plasma Windows-Style System Tray Mod


## Project status

**Release:** 1.0.0
**Target:** KDE Plasma 6.7.x
**Status:** Tested and working on the pinned Plasma Workspace base commit.

This is an unofficial patch, not an upstream KDE feature. Plasma internals may
change between releases, so compatibility with newer Plasma versions is not
guaranteed.


A KDE Plasma System Tray modification that adds a more Windows-like overflow
workflow while preserving Plasma applet behavior.

## Features

- Drag application tray icons from the panel into the overflow popup.
- Drag them back onto the panel at the intended position.
- Reorder visible tray icons.
- Reorder icons inside the popup.
- Reorder built-in Plasma applets in the popup.
- Persist ordering across Plasma restarts.
- Preserve normal click, activation, context-menu, and applet behavior.

## Tested base

This release was built from Plasma Workspace commit:

`668b662b8baafd18d9a544b58d1ccc359c04cb8e`

The patch is intended for Plasma 6.7-era source. Internal Plasma APIs change,
so future releases may require rebasing.

## Repository contents

- `patches/plasma-6.7-systemtray.patch` — final tested patch
- `scripts/install.sh` — clone/build/install the patched System Tray
- `scripts/restore.sh` — restore the System Tray plugin backup created by install
- `scripts/rebuild-after-plasma-update.sh` — compatibility build helper
- `docs/COMPATIBILITY.md` — compatibility notes
- `docs/DEVELOPMENT-NOTES.md` — implementation notes
- `docs/LICENSE-AUDIT.md` — SPDX audit of modified upstream files

## Before installing

Review the patch and run the non-destructive release checks:

```bash
./scripts/check-release.sh
./scripts/install.sh --dry-run
```

The installer creates an immutable stock-plugin backup on first install.

## Install

First run a non-destructive check:

```bash
./scripts/install.sh --dry-run
```

The installer refuses automatic installation when the detected Plasma series is
not 6.7.x unless `--force-version` is supplied.

On first installation it creates an immutable restore backup and will not
overwrite that backup automatically.

If the machine is already running this mod and you have a known stock plugin
binary, seed the restore backup explicitly:

```bash
./scripts/install.sh --backup-from /path/to/stock/org.kde.plasma.systemtray.so
```

Then verify the managed state:

```bash
./scripts/verify.sh
```

## Restore


```bash
./scripts/restore.sh
./scripts/verify.sh
```

## Plasma updates

A Plasma update can replace the patched plugin. To check whether the patch
still applies to another Plasma Workspace source tree:

```bash
./scripts/rebuild-after-plasma-update.sh /path/to/plasma-workspace
```

That helper builds but does not automatically install the result.

## Important

This is an unofficial modification of KDE Plasma Workspace. It is not an
official KDE product or supported KDE configuration.

The patch modifies upstream KDE files and retains their existing SPDX license
headers. See `docs/LICENSE-AUDIT.md`.

## Licensing

Original scripts and documentation created for this project are licensed under
`GPL-2.0-or-later` unless stated otherwise.

The included patch modifies KDE Plasma Workspace files. Those files retain
their respective upstream `GPL-2.0-or-later` or `LGPL-2.0-or-later` licensing
terms and copyright notices. See `LICENSE` and `docs/LICENSE-AUDIT.md` for
details.

This project is an independent, unofficial modification of KDE Plasma
Workspace. It is not an official KDE project and is not endorsed by KDE.

P.S.
Yes I understand no coding whatsoever.
And Yes I made all of this using AI. But hey it works! I really missed that from Windows and now I got it back!
Truth be told I have no idea how GitHub works and I hope people can contribute to this and update it if I am not around without having to
remix it or something like that. Again I have no idea how GitHub works...
