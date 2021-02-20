#!/usr/bin/env bash

set -euxo pipefail
shopt -s failglob

pushd tmp

mkdir -p interrupted_dirs
tar -caf "interrupted_dirs.tar.gz" interrupted_dirs

CHUNKS=3

split --number=$CHUNKS interrupted_dirs.tar.gz interrupted_dirs.tar.gz.part

rm interrupted_dirs.tar.gz

for PART in interrupted_dirs.tar.gz.part* ; do
    mkdir -p $PART.folder
    mv $PART $PART.folder/
done

popd
