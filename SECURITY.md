# Security

This project installs a locally built KDE Plasma System Tray plugin into the
system Qt 6 plugin directory using `sudo`.

Before running the installer:

- review the patch and scripts;
- run `./scripts/install.sh --dry-run`;
- verify that the detected Plasma version and plugin path are correct;
- keep the immutable restore backup created by the installer.

Do not report general KDE Plasma security issues here. Report upstream KDE
security issues through KDE's official security process.

For project-specific installer or restore safety problems, open a GitHub issue
without including private paths, passwords, tokens, or other secrets.
