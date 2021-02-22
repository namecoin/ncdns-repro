#!/usr/bin/env bash

set -euxo pipefail
shopt -s nullglob globstar

print_os_arch () {
    local OS="$1"
    local ARCH="$2"

    # Pre-download tarballs and Git repos
    echo "${CHANNEL}_${OS}_${ARCH}_download_docker_builder:
  timeout_in: 120m
  out_${CHANNEL}_${OS}_${ARCH}_cache:
    folder: out
    fingerprint_script:
      - \"echo out_${CHANNEL}_${OS}_${ARCH}\"
    reupload_on_changes: true
    populate_script:
      - \"mkdir -p out\"
  out1_${CHANNEL}_${OS}_${ARCH}_cache:
    folder: out_cache1
    fingerprint_script:
      - \"echo out1_${CHANNEL}_${OS}_${ARCH}\"
    reupload_on_changes: true
    populate_script:
      - \"mkdir -p out_cache1\"
  git_${CHANNEL}_${OS}_${ARCH}_cache:
    folder: git_clones
    fingerprint_script:
      - \"echo git_${CHANNEL}_${OS}_${ARCH}\"
    reupload_on_changes: true
    populate_script:
      - \"mkdir -p git_clones\"
  interrupted_aa_${CHANNEL}_${OS}_${ARCH}_cache:
    folder: tmp/interrupted_dirs.tar.gz.partaa.folder
    fingerprint_script:
      - \"echo interrupted_aa_${CHANNEL}_${OS}_${ARCH}\"
    reupload_on_changes: true
  interrupted_ab_${CHANNEL}_${OS}_${ARCH}_cache:
    folder: tmp/interrupted_dirs.tar.gz.partab.folder
    fingerprint_script:
      - \"echo interrupted_ab_${CHANNEL}_${OS}_${ARCH}\"
    reupload_on_changes: true
  interrupted_ac_${CHANNEL}_${OS}_${ARCH}_cache:
    folder: tmp/interrupted_dirs.tar.gz.partac.folder
    fingerprint_script:
      - \"echo interrupted_ac_${CHANNEL}_${OS}_${ARCH}\"
    reupload_on_changes: true
  build_script:
    - \"./tools/cirrus_build_project.sh plain-binaries ${CHANNEL} ${OS} ${ARCH} 0\""
    echo ""

    # TODO fine-tune this list
    for PROJECT in compiler.1 compiler.2 goeasyconfig.1 ncdns.1 ncp11.1 ncprop279.1 plain-binaries.1 release.1; do
        PROJECT_BASE=$(echo $PROJECT | cut -d . -f 1)
        if [[ "$PROJECT_BASE" == "compiler" ]]; then
            if [[ "$OS" == "android" ]]; then
                PROJECT_BASE=android-toolchain
            fi
            if [[ "$OS" == "linux" ]]; then
                PROJECT_BASE=gcc
            fi
            if [[ "$OS" == "windows" ]]; then
                PROJECT_BASE=mingw-w64
            fi
            if [[ "$OS" == "osx" ]]; then
                PROJECT_BASE=macosx-toolchain
            fi
        fi
        PROJECT_ITER=$(echo $PROJECT | cut -d . -f 2)
        echo "${CHANNEL}_${OS}_${ARCH}_${PROJECT_BASE}_${PROJECT_ITER}_docker_builder:
  timeout_in: 120m
  out_${CHANNEL}_${OS}_${ARCH}_cache:
    folder: out
    fingerprint_script:
      - \"echo out_${CHANNEL}_${OS}_${ARCH}\"
    reupload_on_changes: true
    populate_script:
      - \"mkdir -p out\"
  out1_${CHANNEL}_${OS}_${ARCH}_cache:
    folder: out_cache1
    fingerprint_script:
      - \"echo out1_${CHANNEL}_${OS}_${ARCH}\"
    reupload_on_changes: true
    populate_script:
      - \"mkdir -p out_cache1\"
  git_${CHANNEL}_${OS}_${ARCH}_cache:
    folder: git_clones
    fingerprint_script:
      - \"echo git_${CHANNEL}_${OS}_${ARCH}\"
    reupload_on_changes: true
    populate_script:
      - \"mkdir -p git_clones\"
  interrupted_aa_${CHANNEL}_${OS}_${ARCH}_cache:
    folder: tmp/interrupted_dirs.tar.gz.partaa.folder
    fingerprint_script:
      - \"echo interrupted_aa_${CHANNEL}_${OS}_${ARCH}\"
    reupload_on_changes: true
  interrupted_ab_${CHANNEL}_${OS}_${ARCH}_cache:
    folder: tmp/interrupted_dirs.tar.gz.partab.folder
    fingerprint_script:
      - \"echo interrupted_ab_${CHANNEL}_${OS}_${ARCH}\"
    reupload_on_changes: true
  interrupted_ac_${CHANNEL}_${OS}_${ARCH}_cache:
    folder: tmp/interrupted_dirs.tar.gz.partac.folder
    fingerprint_script:
      - \"echo interrupted_ac_${CHANNEL}_${OS}_${ARCH}\"
    reupload_on_changes: true
  checkpoint_background_script:
    - sleep 110m
    - ./tools/container-interrupt.sh
  build_script:
    - \"./tools/cirrus_build_project.sh ${PROJECT_BASE} ${CHANNEL} ${OS} ${ARCH} 1\""

        if [[ "$PROJECT" == "release.1" ]]; then
            echo "  binaries_artifacts:
    path: \"${CHANNEL}/**/*\""
        fi

        # Depend on previous project
        if [[ "$PROJECT" == "compiler.1" ]]; then
            echo "  depends_on:
    - \"${CHANNEL}_${OS}_${ARCH}_download\""
        else
            echo "  depends_on:
    - \"${CHANNEL}_${OS}_${ARCH}_${PREV_PROJECT_BASE}_${PREV_PROJECT_ITER}\""
        fi

        local PREV_PROJECT_BASE="$PROJECT_BASE"
        local PREV_PROJECT_ITER="$PROJECT_ITER"
        echo ""
    done
}

(
for CHANNEL in release; do
    print_os_arch linux x86_64
    print_os_arch linux i686
    print_os_arch windows x86_64
    print_os_arch windows i686
    print_os_arch osx x86_64
done
) > .cirrus.yml

# Timeout issues?
# Might want to increase the timeout -- but we're already using the 2 hour max.
# Might want to bump the CPU count -- but that's blocked by cirrus-ci-docs issue #741.
# Might want to split into smaller project sets.
# What is the CPU count limit?  "Linux Containers" docs say 8.0 CPU and 24 GB RAM; "FAQ" says 16.0 CPU.  docker_builder VM's are really 4.0 CPU and 15 GB RAM (12 GB of which is unused by the OS).
