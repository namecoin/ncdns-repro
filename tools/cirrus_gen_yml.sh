#!/usr/bin/env bash

set -euxo pipefail
shopt -s nullglob globstar

print_os_arch () {
    # Pre-download tarballs and Git repos
    echo "${CHANNEL}_download_docker_builder:
  name: \"${CHANNEL} \$CI_RBM_OS \$CI_RBM_ARCH download 1\"
  timeout_in: 120m
  out_${CHANNEL}_cache:
    folder: out
    fingerprint_script:
      - \"echo out ${CHANNEL} \$CI_RBM_OS \$CI_RBM_ARCH\"
    reupload_on_changes: true
    populate_script:
      - \"mkdir -p out\"
  out1_${CHANNEL}_cache:
    folder: out_cache1
    fingerprint_script:
      - \"echo out1 ${CHANNEL} \$CI_RBM_OS \$CI_RBM_ARCH\"
    reupload_on_changes: true
    populate_script:
      - \"mkdir -p out_cache1\"
  git_${CHANNEL}_cache:
    folder: git_clones
    fingerprint_script:
      - \"echo git ${CHANNEL} \$CI_RBM_OS \$CI_RBM_ARCH\"
    reupload_on_changes: true
    populate_script:
      - \"mkdir -p git_clones\"
  interrupted_aa_${CHANNEL}_cache:
    folder: tmp/interrupted_dirs.tar.gz.partaa.folder
    fingerprint_script:
      - \"echo interrupted_aa ${CHANNEL} \$CI_RBM_OS \$CI_RBM_ARCH\"
    reupload_on_changes: true
  interrupted_ab_${CHANNEL}_cache:
    folder: tmp/interrupted_dirs.tar.gz.partab.folder
    fingerprint_script:
      - \"echo interrupted_ab ${CHANNEL} \$CI_RBM_OS \$CI_RBM_ARCH\"
    reupload_on_changes: true
  interrupted_ac_${CHANNEL}_cache:
    folder: tmp/interrupted_dirs.tar.gz.partac.folder
    fingerprint_script:
      - \"echo interrupted_ac ${CHANNEL} \$CI_RBM_OS \$CI_RBM_ARCH\"
    reupload_on_changes: true
  build_script:
    - \"./tools/cirrus_build_project.sh plain-binaries ${CHANNEL} \$CI_RBM_OS \$CI_RBM_ARCH 0\"
  env:
    CIRRUS_LOG_TIMESTAMP: true
  matrix:
    - env:
        CI_RBM_OS: linux
        CI_RBM_ARCH: x86_64
    - env:
        CI_RBM_OS: linux
        CI_RBM_ARCH: i686
    - env:
        CI_RBM_OS: windows
        CI_RBM_ARCH: x86_64
    - env:
        CI_RBM_OS: windows
        CI_RBM_ARCH: i686
    - env:
        CI_RBM_OS: osx
        CI_RBM_ARCH: x86_64"
    echo ""

        echo "${CHANNEL}_docker_builder:"
        echo "  name: \"${CHANNEL} \$CI_RBM_OS \$CI_RBM_ARCH \$CI_RBM_PROJECT_BASE \$CI_RBM_PROJECT_ITER\"
  timeout_in: 120m
  out_${CHANNEL}_cache:
    folder: out
    fingerprint_script:
      - \"echo out ${CHANNEL} \$CI_RBM_OS \$CI_RBM_ARCH\"
    reupload_on_changes: true
    populate_script:
      - \"mkdir -p out\"
  out1_${CHANNEL}_cache:
    folder: out_cache1
    fingerprint_script:
      - \"echo out1 ${CHANNEL} \$CI_RBM_OS \$CI_RBM_ARCH\"
    reupload_on_changes: true
    populate_script:
      - \"mkdir -p out_cache1\"
  git_${CHANNEL}_cache:
    folder: git_clones
    fingerprint_script:
      - \"echo git ${CHANNEL} \$CI_RBM_OS \$CI_RBM_ARCH\"
    reupload_on_changes: true
    populate_script:
      - \"mkdir -p git_clones\"
  interrupted_aa_${CHANNEL}_cache:
    folder: tmp/interrupted_dirs.tar.gz.partaa.folder
    fingerprint_script:
      - \"echo interrupted_aa ${CHANNEL} \$CI_RBM_OS \$CI_RBM_ARCH\"
    reupload_on_changes: true
  interrupted_ab_${CHANNEL}_cache:
    folder: tmp/interrupted_dirs.tar.gz.partab.folder
    fingerprint_script:
      - \"echo interrupted_ab ${CHANNEL} \$CI_RBM_OS \$CI_RBM_ARCH\"
    reupload_on_changes: true
  interrupted_ac_${CHANNEL}_cache:
    folder: tmp/interrupted_dirs.tar.gz.partac.folder
    fingerprint_script:
      - \"echo interrupted_ac ${CHANNEL} \$CI_RBM_OS \$CI_RBM_ARCH\"
    reupload_on_changes: true
  checkpoint_background_script:
    - sleep 110m
    - ./tools/container-interrupt.sh
  build_script:
    - \"./tools/cirrus_build_project.sh \$CI_RBM_PROJECT_BASE ${CHANNEL} \$CI_RBM_OS \$CI_RBM_ARCH 1\""

        echo "  env:
    CIRRUS_LOG_TIMESTAMP: true
  matrix:
    - env:
        CI_RBM_OS: linux
        CI_RBM_ARCH: x86_64
        CI_RBM_COMPILER: gcc
    - env:
        CI_RBM_OS: linux
        CI_RBM_ARCH: i686
        CI_RBM_COMPILER: gcc
    - env:
        CI_RBM_OS: windows
        CI_RBM_ARCH: x86_64
        CI_RBM_COMPILER: mingw-w64
    - env:
        CI_RBM_OS: windows
        CI_RBM_ARCH: i686
        CI_RBM_COMPILER: mingw-w64
    - env:
        CI_RBM_OS: osx
        CI_RBM_ARCH: x86_64
        CI_RBM_COMPILER: macosx-toolchain
  matrix:"
        local PREV_PROJECT_BASE=download
        local PREV_PROJECT_ITER=1
        # TODO fine-tune this list
        for PROJECT in compiler.1 compiler.2 goeasyconfig.1 ncdns.1 ncp11.1 ncprop279.1 plain-binaries.1 release.nosign release.sign; do
            PROJECT_BASE=$(echo $PROJECT | cut -d . -f 1)
            PROJECT_ITER=$(echo $PROJECT | cut -d . -f 2)
            if [[ "$PROJECT_BASE" == "compiler" ]]; then
                PROJECT_BASE="\$CI_RBM_COMPILER"
            fi
            echo "    - env:
        CI_RBM_PROJECT_BASE: ${PROJECT_BASE}
        CI_RBM_PROJECT_ITER: ${PROJECT_ITER}
        CI_RBM_PREV_PROJECT_BASE: ${PREV_PROJECT_BASE}
        CI_RBM_PREV_PROJECT_ITER: ${PREV_PROJECT_ITER}"

            if [[ "$PROJECT_ITER" == "nosign" ]]; then
                echo '      only_if: $CIRRUS_REPO_OWNER != "namecoin"'
            fi

            if [[ "$PROJECT_BASE" == "release" ]]; then
                echo "      binaries_artifacts:
        path: \"${CHANNEL}/**/*\""
            fi

            if [[ "$PROJECT_ITER" == "sign" ]]; then
                echo '      only_if: $CIRRUS_REPO_OWNER == "namecoin"'
                echo "      env:
        SIGN_BUILD: 1
        SIGN_KEY: ENCRYPTED[33d4594d76774e6447dfd9fabee90f6214b34e209fa1c1c2ce93ed1a40447a235b013b78afe85db52d5561651a821be1]
        HOME: /root"
            else
                echo "      env:
        SIGN_BUILD: 0"
            fi

            if [[ "$PROJECT_ITER" != "nosign" ]]; then
                local PREV_PROJECT_BASE="$PROJECT_BASE"
                local PREV_PROJECT_ITER="$PROJECT_ITER"
            fi
        done

        echo "  depends_on:
    - \"${CHANNEL} \$CI_RBM_OS \$CI_RBM_ARCH \$CI_RBM_PREV_PROJECT_BASE \$CI_RBM_PREV_PROJECT_ITER\""

        echo ""
}

(
for CHANNEL in release; do
    print_os_arch
done
) > .cirrus.yml

# Timeout issues?
# Might want to increase the timeout -- but we're already using the 2 hour max.
# Might want to bump the CPU count -- but that's blocked by cirrus-ci-docs issue #741.
# Might want to split into smaller project sets.
# What is the CPU count limit?  "Linux Containers" docs say 8.0 CPU and 24 GB RAM; "FAQ" says 16.0 CPU.  docker_builder VM's are really 4.0 CPU and 15 GB RAM (12 GB of which is unused by the OS).
