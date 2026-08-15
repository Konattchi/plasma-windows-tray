# Building

The normal installer performs a reproducible build from the tested Plasma
Workspace commit:

```bash
./scripts/install.sh --dry-run
./scripts/install.sh
```

The installer clones Plasma Workspace into the user's cache directory, checks
out the tested commit, applies the patch, configures CMake with Ninja, and
builds only the `org.kde.plasma.systemtray` target.

A full Plasma development environment is still required for CMake
configuration. Missing dependencies are reported by CMake.

For compatibility testing against another local Plasma Workspace source tree:

```bash
./scripts/rebuild-after-plasma-update.sh /path/to/plasma-workspace
```

That helper builds only and intentionally does not install the result.
