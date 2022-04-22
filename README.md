# Steam Mutator

**Disclaimer:** I sometimes manually test this against a MiniForums UM700 and
virtualization via QEMU and VMware. This is just an experiment and nothing to be
considered stable in any shape or form, run this if you feel adventurous and you
expect to have your OS broken for no good reason.

This tool allows for SteamOS to be used with persistent system modifications and
AUR packages.

## Features

- Unstrips SteamOS with all the package files that Valve removed to save space
- Will copy over your modifications to the OS across updates

## How is it done?

SteamOS uses [RAUC](https://rauc.io) for its update mechanism. I hook into this
update mechanism with my own post-install script that scans for user scripts to
run additional commands. Examples of such user scripts are shipped with the
software.

## How to install?

*Work in progress, more info soon.*
