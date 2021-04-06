#!/usr/bin/env bash

set -euxo pipefail
shopt -s nullglob globstar

PROJECT=$1
CHANNEL=$2
OS=$3
ARCH=$4
SHOULD_BUILD=$5

echo "Checking VM specs..."
cat /etc/*-release
df -h
lscpu
free -m

echo "Verifying Cirrus YML determinism..."
mv .cirrus.yml .cirrus.yml.bak
./tools/cirrus_gen_yml.sh 2>/dev/null
diff .cirrus.yml .cirrus.yml.bak

echo "Installing rbm deps..."
APT_DEPS="libyaml-libyaml-perl libtemplate-perl libio-handle-util-perl libio-all-perl libio-captureoutput-perl libjson-perl libpath-tiny-perl libstring-shellquote-perl libsort-versions-perl libdigest-sha-perl libdata-uuid-perl libdata-dump-perl libfile-copy-recursive-perl libfile-slurp-perl git runc rsync"
apt-get install -y $APT_DEPS || (sleep 15s && apt-get install -y $APT_DEPS)

echo "Pulling rbm..."
make submodule-update

echo "Configuring rbm..."
# Print logs to Cirrus.
cat rbm.local.conf.example | sed "s/#build_log: '-'/build_log: '-'/g" > rbm.local.conf
# Configure "make clean"
cat tools/rbm.local.conf.onetarget | sed "s/CHANNEL/$CHANNEL/g" | sed "s/ncdns-all/ncdns-$OS-$ARCH/g" >> rbm.local.conf

echo "Patching rbm..."
./tools/patch-tor-to-namecoin.sh

echo "Restoring caches..."
cp -a ./out_cache1/* ./out/ || true
cp -a ./out_cache2/* ./out/ || true

echo "Unpacking interrupted cache..."
./tools/cirrus_unpack_interrupted.sh || true

echo "Unpacking git cache..."
./tools/cirrus_unpack_git.sh || true

if [[ "$PROJECT" == "release" ]]; then
    echo "release project is never cached."
else
    echo "Checking if project is cached..."
    OUTDIR="$(./rbm/rbm showconf $PROJECT output_dir --target $CHANNEL --target ncdns-$OS-$ARCH)"
    OUTFILE="$(./rbm/rbm showconf $PROJECT filename --target $CHANNEL --target ncdns-$OS-$ARCH)"

    if [[ "$SHOULD_BUILD" -eq 0 ]]; then
        echo "Cleaning old outputs..."
        ./tools/clean-old
    fi

    if [[ -e "$OUTDIR/$OUTFILE" ]]; then
        echo "Project cache hit, skipping build."
        SHOULD_BUILD=0
    else
        echo "Project cache miss, proceeding with build."
    fi
fi

# VM has 12 GB of free RAM.  Assuming each of the 4 logical cores takes 1 GB
# during build, that leaves us with 8 GB of unutilized RAM.  Alas, I'm not sure
# that's enough, so this isn't enabled right now.
#echo "Mounting tmpfs..."
#mount -t tmpfs -o size=8G,nr_inodes=40k,mode=1777 tmpfs ./tmp
#df -h

if [[ "$SHOULD_BUILD" -eq 1 ]]; then
    if [[ "$SIGN_BUILD" == "1" ]]; then
        echo "Configuring signing key..."
        export RBM_SIGN_BUILD=1
        export RBM_GPG_OPTS="--local-user jeremy@namecoin.org"
        # Avoid leaking private key to console
        set +x
        echo "$SIGN_KEY" | gpg --import
        set -x
    else
        echo "Signing is disabled."
    fi

    echo "Building project..."
    # If rbm fails, we consider it a success as long as it saved a checkpoint.
    ./rbm/rbm build "$PROJECT" --target "$CHANNEL" --target ncdns-"$OS"-"$ARCH" || [ ! -z "$(ls -A ./tmp/interrupted_dirs/)" ]
else
    #echo "This is a cache-only task, skipping build."
    echo "Skipping build."

    echo "Clearing interrupted cache..."
    rm -rf ./tmp/interrupted_dirs/* || true
fi

# The cache has a size limit, so we need to clean useless data from it.  The
# container-images are very large and seem to be fairly harmless to remove.
# Maybe later if we have more pressure to shrink, we could remove the
# debootstrap-images too.
echo "Cleaning containers..."
rm -rfv out/container-image

echo "Splitting caches..."
rsync -avu --delete ./out/macosx-toolchain ./out_cache1/ || true
rsync -avu --delete ./out/plain-binaries ./out_cache2/ || true
rm -rf ./out/macosx-toolchain || true
rm -rf ./out/plain-binaries || true

echo "Packing git cache..."
./tools/cirrus_pack_git.sh || true

echo "Packing interrupted cache..."
./tools/cirrus_pack_interrupted.sh || true
