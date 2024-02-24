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
# TODO - transfer existing pacman keyring from self to other
run --write pacman-key --populate archlinux --populate holo

# Fix up pacman repo configurations
steamdeck_packages_base_url="https://steamdeck-packages.steamos.cloud/archlinux-mirror"
patch_repo() {
    local name
    name="$1"
    if ! run grep -qE '^\['"$name"'.*\]' /etc/pacman.conf; then
        #echo "Skipping fixup of unused repository $name" >&2
        return
    fi
    echo "Checking correct repository name for $name..." >&2
    local version
    version="${2:-auto}"
    if [ "$version" = "auto" ]; then
        version="rel"
        VERSION_ID=
        eval "$(run cat /etc/os-release | grep '^VERSION_ID=')"
        if [ "$VERSION_ID" != "" ]; then
            for v in "${VERSION_ID}" "${VERSION_ID%.*}"; do
                if curl --fail -sLIo /dev/null "$steamdeck_packages_base_url/$name-$v/os/$(uname -m)/$name-$v.db"; then
                    version="$v"
                    break
                fi
            done
        fi
    fi
    echo "Fixing up repository $name to $name-$version" >&2
    run sed -i 's/^\['"$name"'.*\]/['"$name"'-'"$version"']/' /etc/pacman.conf
}
for name in core community extra holo jupiter kde-unstable multilib testing; do
    for suffix in "" -debug -staging -testing -testing-debug -testing-staging -testing-debug-staging; do
        patch_repo "$name$suffix"
    done
done

# Reinstall fakeroot for makepkg to work
run --write pacman -Sy --noconfirm fakeroot
