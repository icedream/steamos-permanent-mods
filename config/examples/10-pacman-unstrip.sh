#!/bin/bash

#
# Preparation for compiling software for the Deck, for example installing AUR
# packages.
#
# Valve strips out a lot of files from SteamOS to save on space, including
# documentation of packages, header files and other stuff that is useful or even
# critical to compile software. This will reinstall all packages affected by
# this aggressive strip-down, enabling AUR packages to be installed without
# constantly running into these missing files. Do keep an eye on your rootfs
# usage though, you have 5 GB in total to work with.
#
# Has to be run after 00-pacman.sh.
#
# Author: Carl Kittelberger <icedream@icedream.pw>
#

# pacman -Qqk:
#   -Q => query
#   -q => only print package names and path that got modified
#   -k => check each package and list modifications
# awk '{print $1}':
#   extract only package name from each line
# uniq:
#   remove duplicate package names
#
# We take these package names and feed them right back into `pacman -S --noconfirm`,
# forcing a reinstall of these packages.
#
# (normally you'd run `sort` before `uniq` but output is already sorted)
run --write pacman -S --noconfirm $(run pacman -Qqk --color never | awk '{print $1}' | uniq)
