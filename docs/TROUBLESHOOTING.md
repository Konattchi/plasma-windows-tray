# Troubleshooting

## Installer refuses my Plasma version

The public release is guarded for Plasma 6.7.x. Internal Plasma APIs change
between releases, so this is intentional.

Use `--force-version` only after the patch has been rebased and tested against
that Plasma version.

## The mod disappears after a Plasma update

A distribution update can replace the patched System Tray plugin. Re-run the
installer only after confirming compatibility with the updated Plasma version.

## Restore

Run:

```bash
./scripts/restore.sh
./scripts/verify.sh
```

`verify.sh` should report `State: RESTORED BACKUP`.

## Verify current state

```bash
./scripts/verify.sh
```

The script reports whether the installed plugin matches the recorded mod hash,
the immutable stock backup hash, or neither.

## Build warnings

Warnings from unrelated Plasma Workspace components may appear while CMake
configures the source tree. The important result is whether the System Tray
target configures, builds, links, and passes the install-time dependency check.
