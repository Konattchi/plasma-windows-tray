# Contributing

Thanks for considering a contribution.

## Scope

This project is a focused patch against KDE Plasma Workspace's System Tray.
Please keep changes narrowly related to tray overflow, drag/drop, ordering,
compatibility, packaging, or documentation.

## Before submitting a change

1. Run `scripts/check-release.sh`.
2. Build and install the patch on a compatible Plasma 6.7 system.
3. Test:
   - panel -> popup;
   - popup -> panel;
   - visible tray reordering;
   - popup tray reordering;
   - Plasma applet reordering;
   - click and context-menu behavior;
   - persistence after restarting Plasma.
4. Test `scripts/restore.sh` if installer/restore behavior changed.

## Compatibility

The patch targets a specific Plasma Workspace base commit. Changes that update
compatibility to a newer Plasma release should be tested as a separate release
and should update the compatibility documentation and patch metadata.

## Coding style

Preserve upstream KDE style in patched files. Avoid debug logging, stage-number
names, temporary diagnostics, and behavior changes unrelated to the patch.

## Release whitespace check

The frozen patch in `patches/plasma-6.7-systemtray.patch` is intentionally
excluded from repository-level `git diff --check`. It is a validated,
hash-pinned release artifact containing nested diff lines whose whitespace is
part of the frozen patch. Do not reformat it without repeating the full
install/restore/reinstall validation cycle.

Use:

```bash
git diff --cached --check -- . ':(exclude)patches/plasma-6.7-systemtray.patch'
```
