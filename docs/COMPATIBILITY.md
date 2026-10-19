# Compatibility

This patch was developed and tested against KDE Plasma Workspace base commit:

`668b662b8baafd18d9a544b58d1ccc359c04cb8e`

It was tested on Plasma 6.7-era sources.

The patch modifies only the System Tray applet implementation under
`applets/systemtray`.

Because Plasma's internal QML/C++ implementation can change between releases,
do not assume the patch applies cleanly to newer Plasma versions. Rebase and
retest after Plasma updates.

## Plasma 6.8 port (in progress)

The Plasma 6.8.0 System Tray patch was built successfully against upstream tag `v6.8.0` (commit `9d82cf039a17a300c696c87ad32d3113507ed7f9`) and manually tested on CachyOS `plasma-workspace 6.8.0-1.1`.

The port uses one combined patch incorporating the native tooltip changes. The original 6.7 patches remain necessary for 6.7 users. The current installer is **not yet 6.8 compatible**; do not use `--force-version` as a substitute for porting it. A package update may replace a manually installed plugin. The separate plasma-nm wired-network icon mod has not yet been validated on 6.8.
