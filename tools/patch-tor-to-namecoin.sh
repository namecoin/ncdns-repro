#!/usr/bin/env bash

set -euxo pipefail
shopt -s nullglob globstar

cat tor-browser-build/rbm.conf | sed "s/torbrowser/ncdns/g" > rbm.conf
