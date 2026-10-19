# Plasma 6.8.0 compatibility release

## What's new
- Adds the tested Plasma Workspace 6.8.0 System Tray patch, including native Windows-style tooltip behavior.
- Keeps the Plasma 6.7.x compatibility path.
- Selects the correct source patch for supported Plasma versions.
- Extends installer backup/version checks and release validation.

## Validated
- CachyOS/Arch, KDE Plasma 6.8.0.
- Patch application, compilation, installation, live behavior, restoration, reinstallation, and `reapply.sh` passed.
- The original Plasma 6.8.0 System Tray plugin backup remained unchanged.

## Important
- Compatibility is limited to Plasma 6.7.x and **exactly** Plasma 6.8.0; newer Plasma versions must be checked separately.
- First managed installation on 6.8.0 requires a verified stock System Tray plugin backup from that version. Do not reuse a 6.7 backup.
- The combined 6.8 patch can produce three nonfatal trailing-whitespace warnings when applied.

See README and docs/COMPATIBILITY.md for installation and restoration instructions.
