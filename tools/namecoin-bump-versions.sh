#!/usr/bin/env bash

set -euo pipefail
shopt -s nullglob globstar

UPDATE_NEEDED=0

git branch bump-deps
git checkout bump-deps

echo "Configuring username/email..."
git config user.name "NamecoinBot"
git config user.email "ncdns-repro-bump-bot@namecoin.org"

# project Git hashes

for PROJECTPATH in ./projects/*
do
    PROJECT=$(basename ${PROJECTPATH})

    # Tor devs are in charge of their dependencies that we load via symlink
    if [[ -L "${PROJECTPATH}" || "${PROJECT}" = goxcrypto* || "${PROJECT}" = goxnet* || "${PROJECT}" = goxsys* ]]
    then
        continue
    fi

    # Electrum devs are in charge of their dependencies
    PROJECT_IS_ELECTRUM_DEP=1
    grep "project: ${PROJECT}" ./projects/electrum-nmc/config > /dev/null || PROJECT_IS_ELECTRUM_DEP=0
    if [ "$PROJECT_IS_ELECTRUM_DEP" = 1 ]
    then
        continue
    fi

    # x509-signature-splice branch depends on Go version, so it won't always be the latest
    if [ "${PROJECT}" = "gox509signaturesplice" ]
    then
        continue
    fi

    # rbm showconf will fail for projects that don't have a git_hash variable,
    # so we catch the failure and move on to the next project.
    GIT_REV=$(./rbm/rbm showconf ${PROJECT} git_hash) || continue

    VERSION=$(./rbm/rbm showconf ${PROJECT} version)
    VERSION_IS_NUMBER=1
    if (echo "${GIT_REV}" | grep "^${VERSION}")
    then
        # The version is a Git hash rather than a number.
        VERSION_IS_NUMBER=0
    fi

    GIT_URL=$(./rbm/rbm showconf ${PROJECT} git_url)

    REMOTE_TAGS=$(git ls-remote --tags "${GIT_URL}")
    if [ "${REMOTE_TAGS}" = "" ] || [ "${VERSION_IS_NUMBER}" = 0 ]
    then
        # Either there are no tags on the remote Git repo, or this project does
        # not use a tagged version.  Use HEAD instead of a tag.
        LATEST_TAG=HEAD
        LATEST_TAG_HASH=$(git ls-remote "${GIT_URL}" HEAD | awk '{print $1}')
    else
        LATEST_TAG=$(git ls-remote --tags "${GIT_URL}" | grep -v '\^{}' | awk '{print $2}' | awk -F"/" '{print $3}' | sort -V | grep -v "weekly" | tail --lines=1)

        # We use tail here because we want ${LATEST_TAG}^{} if it exists (it's
        # the one that the GitHub UI shows).
        LATEST_TAG_HASH=$(git ls-remote "${GIT_URL}" ${LATEST_TAG} ${LATEST_TAG}^{} | tail --lines=1 | awk '{print $1}')
    fi
    LATEST_INFO=$(git ls-remote "${GIT_URL}" HEAD ${LATEST_TAG} ${LATEST_TAG}^{})

    PROJECT_UPDATE_NEEDED=0
    echo "${LATEST_INFO}" | grep ${GIT_REV} > /dev/null || PROJECT_UPDATE_NEEDED=1
    if [ "${PROJECT_UPDATE_NEEDED}" = 1 ]
    then
        UPDATE_NEEDED=1
        echo "${PROJECT}: rbm uses ${GIT_REV}, latest at remote ${GIT_URL} are:
${LATEST_INFO}"

        sed --in-place "s/${GIT_REV}/${LATEST_TAG_HASH}/g" "./projects/${PROJECT}/config"
        if [ "${VERSION_IS_NUMBER}" = 1 ]
        then
            VERSION_STRIPPED=$(echo ${VERSION} | grep --only-matching -E '[0-9\.]+')
            LATEST_VERSION_STRIPPED=$(echo ${LATEST_TAG} | grep --only-matching -E '[0-9\.]+')
            sed --in-place "s/${VERSION_STRIPPED}/${LATEST_VERSION_STRIPPED}/g" "./projects/${PROJECT}/config"
        fi
        git add "./projects/${PROJECT}/config"
        git commit --message="Bump ${PROJECT}"
    fi
done

# ncdns-nsis dependencies

BIND_VERSION=$(./rbm/rbm showconf ncdns-nsis var/bind_version)
LATEST_BIND_VERSION=$(curl https://ftp.isc.org/isc/bind/ | grep --only-matching '"[0-9]*\.[0-9]*\.[0-9]*/"' | tail --lines=1 | grep --only-matching '[0-9]*\.[0-9]*\.[0-9]*')

if [ "${BIND_VERSION}" != "(${LATEST_BIND_VERSION})" ]
then
    UPDATE_NEEDED=1
    echo "BIND: ncdns-nsis uses ${BIND_VERSION}, latest tag is ${LATEST_BIND_VERSION}"

    echo sed --in-place "s/${BIND_VERSION}/${LATEST_BIND_VERSION}/g" "./projects/ncdns-nsis/config"
    git add "./projects/ncdns-nsis/config"
    git commit --message="Bump BIND"
fi

CONSENSUSJ_VERSION=$(./rbm/rbm showconf ncdns-nsis var/consensusj_namecoin_version)
LATEST_CONSENSUSJ_VERSION=$(curl https://www.namecoin.org/download/betas/ | grep --only-matching 'ConsensusJ-Namecoin/[0-9\.]*' | tail --lines=1 | grep --only-matching '[0-9\.]*')

if [ "${CONSENSUSJ_VERSION}" != "(${LATEST_CONSENSUSJ_VERSION})" ]
then
    UPDATE_NEEDED=1
    echo "ConsensusJ: ncdns-nsis uses ${CONSENSUSJ_VERSION}, latest tag is ${LATEST_CONSENSUSJ_VERSION}"

    echo sed --in-place "s/${CONSENSUSJ_VERSION}/${LATEST_CONSENSUSJ_VERSION}/g" "./projects/ncdns-nsis/config"
    git add "./projects/ncdns-nsis/config"
    git commit --message="Bump ConsensusJ"
fi

NAMECOIN_VERSION=$(./rbm/rbm showconf ncdns-nsis var/namecoin_core_version)
LATEST_NAMECOIN_VERSION=$(curl https://www.namecoin.org/download/ | grep --only-matching -E 'namecoin-core-[0-9\.]+' | head --lines=1 | grep --only-matching -E '[0-9\.]+')

if [ "${NAMECOIN_VERSION}" != "(${LATEST_NAMECOIN_VERSION})" ]
then
    UPDATE_NEEDED=1
    echo "Namecoin Core: ncdns-nsis uses ${NAMECOIN_VERSION}, latest tag is ${LATEST_NAMECOIN_VERSION}"

    sed --in-place "s/${NAMECOIN_VERSION}/${LATEST_NAMECOIN_VERSION}/g" "./projects/ncdns-nsis/config"
    git add "./projects/ncdns-nsis/config"
    git commit --message="Bump Namecoin Core"
fi

DNSSEC_TRIGGER_VERSION=$(./rbm/rbm showconf ncdns-nsis var/dnssec_trigger_version)
LATEST_DNSSEC_TRIGGER_VERSION=$(curl https://www.nlnetlabs.nl/downloads/dnssec-trigger/ | grep --only-matching -E 'dnssec_trigger_setup_[0-9\.]+.exe' | tail --lines=1 | grep --only-matching -E '[0-9\.]+[0-9]')

if [ "${DNSSEC_TRIGGER_VERSION}" != "(${LATEST_DNSSEC_TRIGGER_VERSION})" ]
then
    UPDATE_NEEDED=1
    echo "DNSSEC-Trigger: ncdns-nsis uses ${DNSSEC_TRIGGER_VERSION}, latest tag is ${DNSSEC_TRIGGER_VERSION}"

    echo sed --in-place "s/${DNSSEC_TRIGGER_VERSION}/${LATEST_DNSSEC_TRIGGER_VERSION}/g" "./projects/ncdns-nsis/config"
    git add "./projects/ncdns-nsis/config"
    git commit --message="Bump DNSSEC-Trigger"
fi

# tor-browser-build submodule
# We do this step last so that if upstream tor-browser-build breaks things,
# we're already done invoking rbm.

GIT_TAG=$(git submodule status tor-browser-build | awk '{print $3}')

GIT_URL=https://git.torproject.org/builders/tor-browser-build.git

LATEST_TAG=$(git ls-remote --tags "${GIT_URL}" | grep 'tbb' | grep -v 'android' | grep -v '\^{}' | awk '{print $2}' | awk -F"/" '{print $3}' | grep 'a' | sort -V | tail --lines=1)
if [ "${GIT_TAG}" != "(${LATEST_TAG})" ]
then
    UPDATE_NEEDED=1
    echo "tor-browser-build: submodule uses ${GIT_TAG}, latest tag is ${LATEST_TAG}"

    pushd tor-browser-build
    # Undo any patches we did to tor-browser-build
    git reset --hard HEAD
    git clean -dfx

    # Bump the tor-browser-build version
    git fetch origin
    git checkout "${LATEST_TAG}"
    popd

    git add "tor-browser-build"
    git commit --message="Bump tor-browser-build"
fi

if [ "$UPDATE_NEEDED" = 1 ]
then
    echo "An update is required."

    if curl -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/${CIRRUS_REPO_FULL_NAME}/pulls?state=open&head=NamecoinBot:bump-deps" | grep -i "NamecoinBot:bump-deps"
    then
        echo "A bump PR is already open; exiting."
        exit 0
    fi

    echo "No bump PR is currently open; proceeding."

    set +x
    echo "Adding deploy key..."
    mkdir -p ~/.ssh
    touch ~/.ssh/id_ed25519
    chmod 0600 ~/.ssh/id_ed25519
    echo "${DEPLOY_KEY}" > ~/.ssh/id_ed25519

    echo "Pinning GitHub SSH public key..."
    echo '|1|x91VhqWighPtR2VjK37WcX5AUBM=|eLqicTE1vy85GxLqGTY1T2o3aTk= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==' >> ~/.ssh/known_hosts

    echo "Adding deploy remote..."
    git remote add deploy "git@github.com:NamecoinBot/ncdns-repro.git"

    echo "Pushing branch..."
    git push --force deploy bump-deps

    echo "Requesting pull..."
    curl -X "POST" -u "NamecoinBot:${PR_TOKEN}" -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/${CIRRUS_REPO_FULL_NAME}/pulls" -d '{"head": "NamecoinBot:bump-deps", "base": "master", "title": "Bump dependencies", "maintainer_can_modify": true}'

    echo "Pull request submitted!"
fi
