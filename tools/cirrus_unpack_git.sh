#!/usr/bin/env bash

set -euxo pipefail
shopt -s failglob

for PROJECT in ./git_index/*
do
    PROJECT_BASE="$(basename $PROJECT)"

    # It's possible that the cache contains a project that was removed from the
    # build sometime after the cache was saved.  In such a case, unpacking it
    # would result in "No such file or directory", so we just discard it
    # instead.
    if [[ -d "./git_clones/${PROJECT_BASE}/.git" ]]
    then
        mv "${PROJECT}" "./git_clones/${PROJECT_BASE}/.git/index"
    else
        rm "${PROJECT}"
    fi
done
