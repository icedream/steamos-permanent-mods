# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.5] - 2024-02-24

### Fixed

- Fix OS of current install instead of new install being used to patch
  repositories in pacman.conf.

## [0.0.4] - 2024-02-24

### Fixed

- Fix pacman breakage due to faulty keyring transfer.
- Fix additional internal commands being printed in stderr which may confuse
  during debugging.

### Changed

- Switch to Decky Loader release install script.

### Removed

- Removed pacman keyring transfer. This is only relevant for installs with
  custom installed keyrings, normal installation of Arch or Holo packages will
  not be affected.

## [0.0.3] - 2023-11-23

### Fixed

- Fix pacman no longer working due to changes on the SteamOS packages server.

## [0.0.2] - 2022-05-22

### Added

- Added code to detect and install/configure packages for VirtIO GPU in
  50-alien.sh example user script.
- Users can now set `GRUB_NO_COPY_CONFIG=1` in
  /etc/default/steamos-permanent-mods to skip copying grub configuration before
  update-grub in 90-grub.sh example user script.
- Users can now set `GRUB_REMOVE_FBCON_ROTATE=1` in
  /etc/default/steamos-permanent-mods to remove the kernel commandline parameter
  that causes display rotation to occur.

## [0.0.1] - 2022-04-22

### Added

- Added post-hook script to reproduce modifications to the system through user scripts.
- Added lots of documentation.

[0.0.5]: https://github.com/icedream/steamos-permanent-mods/releases/tag/v0.0.5
[0.0.4]: https://github.com/icedream/steamos-permanent-mods/releases/tag/v0.0.4
[0.0.3]: https://github.com/icedream/steamos-permanent-mods/releases/tag/v0.0.3
[0.0.2]: https://github.com/icedream/steamos-permanent-mods/releases/tag/v0.0.2
[0.0.1]: https://github.com/icedream/steamos-permanent-mods/releases/tag/v0.0.1
