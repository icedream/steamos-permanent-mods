#!/bin/bash

#
# This simply enables SSH.
#
# I put the package install for openssh in just in case Valve ever removes this.
# If the package is pre-installed, it skips installation.
#
# Author: Carl Kittelberger <icedream@icedream.pw>
#

if systemctl is-enabled sshd >/dev/null 2>/dev/null
then
    echo "Reenabling SSH as it is currently enabled…" >&2

    # Install openssh package (-S openssh) but only if not installed yet (--needed)
    run --write pacman -S --noconfirm --needed openssh

    # Enable the service
    run --write systemctl enable sshd.service
else
    echo "SSH currently disabled, leaving as-is." >&2
fi
