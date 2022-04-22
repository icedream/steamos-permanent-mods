#!/bin/bash

#
# Install KDE Connect as a system package. (Seemingly there's no Flatpak for
# this?)
#
# Author: Carl Kittelberger
#

# Check if user already installed KDE Connect as a system package
if run --slot=self pacman -Qq kdeconnect >/dev/null 2>/dev/null
then
    # Do the same on the new install
    echo "Reinstalling KDE Connect as it is currently installed…" >&2
    run --write yay -S --noconfirm kdeconnect
else
    echo "KDE Connect was not previously manually installed, skipping." >&2
fi
