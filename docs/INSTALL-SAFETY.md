# Installation safety

The installer is intentionally conservative.

- It discovers the installed Qt 6 plugin directory instead of assuming `/usr/lib`.
- It checks the installed Plasma major/minor series.
- It refuses non-6.7 installs unless `--force-version` is explicitly provided.
- The first restore backup is immutable and is never overwritten automatically.
- `--backup-from PATH` lets an already-modded machine seed the immutable backup with a known stock plugin.
- `verify.sh` compares the currently installed plugin against hashes recorded during installation.
- `restore.sh` verifies the backup hash before and after copying it.
- The update helper builds only; it does not automatically install after a Plasma update.

## Root-owned backup sources

`--backup-from` also accepts a stock plugin stored in a root-only directory.
The installer validates and reads that source through `sudo`, then creates the
immutable restore backup in the user's state directory with normal user
ownership.
