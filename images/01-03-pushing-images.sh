#!/usr/bin/env sh

source helpers.bash

if [ -z "${REGISTRY_USER}" ]; then
    	echo "Please set REGISTRY_USER to a user on quay.io"
    	exit 1
fi

run_podman_no_prompt logout quay.io

setup

QUAY_IMAGE=quay.io/$REGISTRY_USER/tutorial:image

# Image push will fail -> we need to login.
run_podman push $IMAGE $QUAY_IMAGE
clear

# Login and repush.
run_podman login -u $REGISTRY_USER quay.io

run_podman push $IMAGE $QUAY_IMAGE
clear

# Show that push also works with a single argument.
run_podman tag $IMAGE $QUAY_IMAGE

run_podman push $QUAY_IMAGE
clear

# Push to a local directory to highlight that there are several "transports".
tmp=$(mktemp -d -p .)
run_podman push $QUAY_IMAGE dir:$tmp

run_command tree dir:$tmp
clear

# Open the transports man page and browse through it to give a feeling for what's supported.
run_command man containers-transports
rm -rf $tmp
