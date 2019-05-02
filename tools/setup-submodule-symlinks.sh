#!/usr/bin/env bash

# This script inits tor-browser-build as a Git submodule of ncdns-repro, unless
# ncdns-repro is inside a tor-browser-build tree (e.g. as a Git submodule of
# tor-browser-build), in which case it uses the parent tor-browser-build.

set -euo pipefail
shopt -s nullglob globstar

ncdnsdir=$(pwd)
parentdir=$(dirname "${ncdnsdir}")
parentbase=$(basename "${parentdir}")

if [ "${parentbase}" == "tor-browser-build" ]; then
  if [ -e tor-browser-build ]; then
    rm tor-browser-build || rmdir tor-browser-build || mv tor-browser-build tor-browser-build-backup
  fi
  ln -s -T .. tor-browser-build
else
  git submodule update --init
  make -C tor-browser-build submodule-update
fi

cp tor-browser-build/projects/tor-browser/pe_checksum_fix.py projects/ncdns-nsis/
