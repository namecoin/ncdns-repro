#!/usr/bin/env bash

set -euxo pipefail
shopt -s failglob

pushd tmp

cat interrupted_dirs.tar.gz.part*.folder/interrupted_dirs.tar.gz.part* > interrupted_dirs.tar.gz

rm -rf interrupted_dirs.tar.gz.part*.folder

tar -xaf interrupted_dirs.tar.gz

rm interrupted_dirs.tar.gz

popd
