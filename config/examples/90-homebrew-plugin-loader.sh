#!/bin/bash

#
# This really just runs the usual install script for Steam Deck Homebrew Plugin
# Loader (nightly version) straight from the GitHub.
#
# If you installed the stable version of Steam Deck Homebrew Plugin Loader you
# do NOT need this. The difference is the nightly version will want to install
# straight to /etc instead of your home partition, and also this script at least
# occasionally will keep the plugin loader up to date for you, whereas with
# stable you have to check for updates yourself.
#
# Author: Carl Kittelberger <icedream@icedream.pw>
#

curl -L https://github.com/SteamDeckHomebrew/PluginLoader/raw/main/dist/install_nightly.sh |\
    run --write sh
