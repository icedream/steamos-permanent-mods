# Steam Mutator

**Disclaimer:** I test this against a real Steam Deck and sometimes manually
test this against a MiniForums UM700 and virtualization via QEMU and VMware.
This is just an experiment and nothing to be considered stable in any shape or
form, run this if you feel adventurous and you expect to have your OS broken for
no good reason.

This tool allows for SteamOS to be used with persistent system modifications and
AUR packages.

## Features

User scripts are shipped with the software to automatically do these things:

- Enable SSH server
- Enable pacman and yay to work properly
- Restore development files necessary to compile software for SteamOS/Steam Deck
- Make SteamOS support non-Deck hardware
- Install SteamOS Homebrew Plugin Loader development version

## How is it done?

SteamOS uses [RAUC](https://rauc.io) for its update mechanism. I hook into this
update mechanism with my own post-install script that scans for user scripts to
run additional commands. Examples of such user scripts are shipped with the
software.

## How to install?

*Work in progress, more info soon.*

### From Git/GitHub source archive

    ./autogen.sh
    ./configure --prefix=/usr/local --sysconfdir=/etc [--options…]
    make

To install to system run `make install` as `root` user.

Afterwards, follow the "Manual setup" section below.

### From source distribution archive

    ./configure --prefix=/usr/local --sysconfdir=/etc [--options…]
    make

To install to system run `make install` as `root` user.

Afterwards, follow the "Manual setup" section below.

### Manual setup

You will have to manually edit the file `/etc/rauc/system.conf` as follows:

```diff
-post-install=/usr/lib/rauc/post-install.sh
+post-install=/usr/local/lib/steamos-permanent-mods/post-install.sh
```

Now restart rauc by running

    sudo systemctl restart rauc

From here onwards new SteamOS updates will run this app and it will copy itself
and all configuration over to the new rootfs.

Then go to `/usr/local/etc/steamos-permanent-mods/` and read the `README.md`
file there for more information. You can start using some of the shipped example
scripts by symlinking them, for example this would enable the two scripts to
restore all stripped files and enable pacman and yay to be fully usable:

    ln -s ../../share/steamos-permanent-mods/examples/00-pacman.sh
    ln -s ../../share/steamos-permanent-mods/examples/10-pacman-unstrip.sh

I highly encourage you to explore the code of the shipped scripts since there is
a lot of included commentary.

If you want to immediately apply these scripts, run the steamos-atomupd-client
command that is referenced in the aforementioned readme file:

    /usr/sbin/steamos-atomupd-client \
        --manifest /etc/steamos-atomupd/manifest.json -d
