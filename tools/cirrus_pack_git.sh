#!/usr/bin/env bash

set -euxo pipefail
shopt -s failglob

for PROJECT in ./git_clones/*
do
    PROJECT_BASE=$(basename $PROJECT)
    mv ${PROJECT}/.git/index ./git_index/${PROJECT_BASE}
done

echo "Final git cache usage:"
du -h -d1 ./git_clones/
