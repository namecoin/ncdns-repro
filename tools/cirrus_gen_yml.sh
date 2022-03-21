#!/usr/bin/env bash

set -euxo pipefail
shopt -s nullglob globstar

print_os_arch () {
    local OS="$1"
    local ARCH="$2"

    # Pre-download tarballs and Git repos
    echo "${CHANNEL}_${OS}_${ARCH}_download_task:
  compute_engine_instance:
    image_project: cirrus-images
    image: family/docker-builder
    platform: linux
    cpu: 1
    memory: 3G
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
  out2_${CHANNEL}_${OS}_${ARCH}_cache:
    folder: out_cache2
    fingerprint_script:
      - \"echo out2_${CHANNEL}_${OS}_${ARCH}\"
    reupload_on_changes: true
    populate_script:
      - \"mkdir -p out_cache2\"
  out3_${CHANNEL}_${OS}_${ARCH}_cache:
    folder: out_cache3
    fingerprint_script:
      - \"echo out3_${CHANNEL}_${OS}_${ARCH}\"
    reupload_on_changes: true
    populate_script:
      - \"mkdir -p out_cache3\"
  git_${CHANNEL}_${OS}_${ARCH}_cache:
    folder: git_clones
    fingerprint_script:
      - \"echo git_${CHANNEL}_${OS}_${ARCH}\"
    reupload_on_changes: true
    populate_script:
      - \"mkdir -p git_clones\"
  gitindex_${CHANNEL}_${OS}_${ARCH}_cache:
    folder: git_index
    fingerprint_script:
      - \"echo gitindex_${CHANNEL}_${OS}_${ARCH}\"
    reupload_on_changes: true
    populate_script:
      - \"mkdir -p git_index\"
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
    echo "  env:
    CIRRUS_LOG_TIMESTAMP: true
    BUMP_DEPS: 0
    RBM_NUM_PROCS: 1"
    echo ""

    # TODO fine-tune this list
    # Use "para" prefix to run with 8 threads; otherwise will use 1 thread.
    for PROJECT in clang.para1 compiler.para1 goeasyconfig.1 ncdns.1 ncprop279.1 plain-binaries.1 release.nosign release.sign; do
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
        PARA_THREADS=1
        PARA_RAM=3
        if echo $PROJECT_ITER | grep -q para ; then
            PARA_THREADS=8
            PARA_RAM=16
        fi
        echo "${CHANNEL}_${OS}_${ARCH}_${PROJECT_BASE}_${PROJECT_ITER}_task:
  compute_engine_instance:
    image_project: cirrus-images
    image: family/docker-builder
    platform: linux
    cpu: ${PARA_THREADS}
    memory: ${PARA_RAM}G
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
  out2_${CHANNEL}_${OS}_${ARCH}_cache:
    folder: out_cache2
    fingerprint_script:
      - \"echo out2_${CHANNEL}_${OS}_${ARCH}\"
    reupload_on_changes: true
    populate_script:
      - \"mkdir -p out_cache2\"
  out3_${CHANNEL}_${OS}_${ARCH}_cache:
    folder: out_cache3
    fingerprint_script:
      - \"echo out3_${CHANNEL}_${OS}_${ARCH}\"
    reupload_on_changes: true
    populate_script:
      - \"mkdir -p out_cache3\"
  git_${CHANNEL}_${OS}_${ARCH}_cache:
    folder: git_clones
    fingerprint_script:
      - \"echo git_${CHANNEL}_${OS}_${ARCH}\"
    reupload_on_changes: true
    populate_script:
      - \"mkdir -p git_clones\"
  gitindex_${CHANNEL}_${OS}_${ARCH}_cache:
    folder: git_index
    fingerprint_script:
      - \"echo gitindex_${CHANNEL}_${OS}_${ARCH}\"
    reupload_on_changes: true
    populate_script:
      - \"mkdir -p git_index\"
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
    # 110m caused the 2hr task timeout to be hit while the cache was uploading
    # for macosx-toolchain, which broke subsequent builds.
    - sleep 105m
    - ./tools/container-interrupt.sh
  build_script:
    - \"./tools/cirrus_build_project.sh ${PROJECT_BASE} ${CHANNEL} ${OS} ${ARCH} 1\""

        if [[ "$PROJECT_BASE" == "release" ]]; then
            echo "  binaries_artifacts:
    path: \"${CHANNEL}/**/*\""
        fi

        if [[ "$PROJECT_ITER" == "sign" ]]; then
            echo '  only_if: $CIRRUS_REPO_OWNER == "namecoin" && "$CIRRUS_PR" == ""'
            echo "  env:
    SIGN_BUILD: 1
    SIGN_KEY: ENCRYPTED[33d4594d76774e6447dfd9fabee90f6214b34e209fa1c1c2ce93ed1a40447a235b013b78afe85db52d5561651a821be1]
    HOME: /root"
        else
            echo "  env:
    SIGN_BUILD: 0"
        fi
        echo "  env:
    CIRRUS_LOG_TIMESTAMP: true
    BUMP_DEPS: 0
    RBM_NUM_PROCS: $PARA_THREADS"
        if [[ "$PROJECT_ITER" == "nosign" ]]; then
            echo '  only_if: $CIRRUS_REPO_OWNER != "namecoin" || "$CIRRUS_PR" != ""'
        fi

        # Depend on previous project
        if [[ "$PROJECT" == "clang.para1" ]]; then
            echo "  depends_on:
    - \"${CHANNEL}_${OS}_${ARCH}_download\""
        else
            echo "  depends_on:
    - \"${CHANNEL}_${OS}_${ARCH}_${PREV_PROJECT_BASE}_${PREV_PROJECT_ITER}\""
        fi

        if [[ "$PROJECT_ITER" != "nosign" ]]; then
            local PREV_PROJECT_BASE="$PROJECT_BASE"
            local PREV_PROJECT_ITER="$PROJECT_ITER"
        fi
        echo ""
    done
}

(
echo "# This file is auto-generated by tools/cirrus_gen_yml.sh -- do not edit manually!"
echo ""
for CHANNEL in release; do
    print_os_arch linux x86_64
    print_os_arch linux i686
    print_os_arch windows x86_64
    print_os_arch windows i686
    print_os_arch osx x86_64
done

echo 'bump_task:
  compute_engine_instance:
    image_project: cirrus-images
    image: family/docker-builder
    platform: linux
    cpu: 1
    memory: 3G
  bump_script:
    - "./tools/cirrus_build_project.sh null null null null 0"
  env:
    BUMP_DEPS: 1
    RBM_NUM_PROCS: 1
    DEPLOY_KEY: ENCRYPTED[7969cc42abbc36c75c5673f2227e2eeec92577391c28c678243f95e01edffa17137e52cbddbe3e409cdab78a637edec5]
    PR_TOKEN: ENCRYPTED[91c45714bbbcf5b1fbb124475368332fcec4020258c5c4316ea9d07e3933982c6d179b925d6f7488978528ca99a737f3]
  only_if: $CIRRUS_REPO_OWNER == "namecoin" && $CIRRUS_PR == ""'
) > .cirrus.yml

# Timeout issues?
# Might want to increase the timeout -- but we're already using the 2 hour max.
# Might want to bump the CPU count -- but that's blocked by cirrus-ci-docs issue #741.
# Might want to split into smaller project sets.
# What is the CPU count limit?  "Linux Containers" docs say 8.0 CPU and 24 GB RAM; "FAQ" says 8 CPU for a single task.  docker_builder VM's are really 4.0 CPU and 15 GB RAM (12 GB of which is unused by the OS).
