#!/bin/sh -e

#
# Versioning script, generates a short app version string based on Git metadata.
#
# Author: Carl Kittelberger <icedream@icedream.pw>
#

(git describe --tags 2>/dev/null || printf '0.0.0') | tr -d 'v\n'
