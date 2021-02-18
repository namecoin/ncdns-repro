#!/usr/bin/env bash

# https://unix.stackexchange.com/a/299198
descendent_pids() {
    pids=$(pgrep -P $1)
    echo $pids
    for pid in $pids; do
        descendent_pids $pid
    done
}

build_pid=$(pgrep -f '\./build')
echo $build_pid
descendent_pids $build_pid
