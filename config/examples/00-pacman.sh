#!/bin/bash

#
# Preparation for Pacman commands to work properly.
#
# Has to be run before any other script that runs pacman or yay commands.
# You most likely want this.
#
# Author: Carl Kittelberger <icedream@icedream.pw>
#

# Preinitialize some files from factory for pacman commands to work
run systemd-tmpfiles --create --boot -E \
    /usr/lib/tmpfiles.d/var.conf \
    /usr/lib/tmpfiles.d/steamos.conf

# Initialize pacman keyring
run --write pacman-key --init
run --write pacman-key --populate archlinux --populate holo

# Reinstall fakeroot for makepkg to work
run --write pacman -S --noconfirm fakeroot
