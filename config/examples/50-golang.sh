#!/bin/bash

#
# This simply install Golang.
#
# Author: Carl Kittelberger <icedream@icedream.pw>
#

# Install go package
run --write pacman -S --noconfirm --needed go
