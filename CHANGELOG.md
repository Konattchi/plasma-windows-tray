# Changelog

## 1.0.0

Initial public release, with post-release hardening kept within the 1.0.0 line.

### Added

- Windows-style compact overflow for application-owned system tray items.
- Drag-and-drop between the panel tray and popup.
- Persistent ordering of visible tray icons.
- Persistent ordering of popup tray icons.
- Persistent ordering of built-in Plasma applets.
- Exact popup-to-panel placement using stable target identity.
- Native Plasma theme-aware tooltips for the popup header controls.
- Safe install, restore, verify, and compatibility-build helper scripts.
- `reapply.sh` for safely restoring the mod after Plasma package updates overwrite the patched plugin.
- Immutable stock-plugin backup and Plasma 6.7 compatibility guard.
- Non-destructive installer and reapply dry-run checks.
- Release checks for both patch hashes, shell syntax, executable script modes, privacy residue, and publication placeholders.

### Verified

- End-to-end installation on KDE Plasma 6.7.4.
- Restore to the immutable stock-plugin backup.
- Reinstallation after restore.
- Reapplication after a Plasma package update replaced the modified System Tray plugin.
- Tray icon ordering persists across temporary removal and reapplication of the mod.
