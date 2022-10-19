#!/usr/bin/env sh

source helpers.bash

setup

tmp=$(mktemp -d -p .)
user="tutorial"
pass="psssst"
port="5000"

export PODMAN_REGISTRY_WORKDIR=$tmp
export PODMAN=$PODMAN

# Stop the potentially running registry first.
#./utils/podman-registry -P $port stop

# Let's first start a local registry and show the credentials.
# User and password are used later on to login.
run_command ./utils/podman-registry start -u $user -p $pass -P $port

run_podman push $IMAGE localhost:$port/tutorial/image:latest

rm -rf $tmp
