# Compatibility

This patch was developed and tested against KDE Plasma Workspace base commit:

`668b662b8baafd18d9a544b58d1ccc359c04cb8e`

It was tested on Plasma 6.7-era sources.

The patch modifies only the System Tray applet implementation under
`applets/systemtray`.

Because Plasma's internal QML/C++ implementation can change between releases,
do not assume the patch applies cleanly to newer Plasma versions. Rebase and
retest after Plasma updates.
