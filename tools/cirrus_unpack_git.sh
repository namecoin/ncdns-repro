#!/usr/bin/env bash

set -euxo pipefail
shopt -s failglob

for PROJECT in ./git_index/*
do
    PROJECT_BASE=$(basename $PROJECT)
    mv ${PROJECT} ./git_clones/${PROJECT_BASE}/.git/index
done
