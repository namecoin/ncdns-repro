#!/usr/bin/env bash

set -euxo pipefail
shopt -s nullglob globstar

pushd tor-browser-build
# Undo any of Namecoin's patches that might have been done previously.
git reset --hard HEAD
git clean -dfx

# The checkpoint patch is disabled while we evaluate whether the move to 8x
# CPU's per VM is sufficient to build within a single task time limit.
#patch -p1 < ../tools/checkpoints.patch

popd

# Rename torbrowser to ncdns
# Use ncdns_version from ncdns project
cat tor-browser-build/rbm.conf | sed "s/torbrowser/ncdns/g" | sed "s/ncdns_version: '.*'/ncdns_version: '[% pc(\"ncdns\", \"version\") %]'/g" > rbm.conf
