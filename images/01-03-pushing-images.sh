#!/usr/bin/env sh

source helpers.bash

if [ -z "${REGISTRY_USER}" ]; then
    	echo "Please set REGISTRY_USER to a user on quay.io"
    	exit 1
fi

run_podman_no_prompt logout quay.io

setup

QUAY_IMAGE=quay.io/$REGISTRY_USER/tutorial:image

run_podman push $IMAGE $QUAY_IMAGE
clear

run_podman login -u $REGISTRY_USER quay.io

run_podman push $IMAGE $QUAY_IMAGE
clear

run_podman tag $IMAGE $QUAY_IMAGE

run_podman push $QUAY_IMAGE
clear

tmp=$(mktemp -d -p .)
run_podman push $QUAY_IMAGE dir:$tmp

run_command tree dir:$tmp
clear

run_command man containers-transports
rm -rf $tmp
