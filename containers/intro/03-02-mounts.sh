#!/usr/bin/env sh

source helpers.bash

podman system reset -f
setup

# NOTE: run `sudo setenforce 0` on an SELinux-enabled machine.  Going into the
# details of SELinux is beyond the scope of this tutorial.  Another tutorial
# will elaborate on how bind mounts can work with SELinux and rootless
# containers.

# Let's first create a directory that we can bind mount during this tutorial.
# The idea is to illustrate the different between bind-mounting and named
# volumes on the host.
tmp=$(mktemp -d)
echo 11111 > $tmp/1
echo 22222 > $tmp/2
echo 33333 > $tmp/3
clear

# First, show the man page of `podman-{create,run}` and look for `--mount`.
# Go through the various options and knobs.  Make sure to mention that most
# users will be happier using `--volume` but if they need more flexibility,
# it is good to know that `--mount` exists.
run_command man podman-create
clear

# Let's show the same example from the `--volume` tutorial.
run_command tree $tmp

run_command cat $tmp/*
clear

# Simple bind mount.
run_command podman run --rm --mount type=bind,src=$tmp,dst=/test $IMAGE cat /test/1
clear

# Bind mount with read-only option.
run_command podman run --rm --mount type=bind,src=$tmp,dst=/test,ro=true $IMAGE touch /test/4
clear

# Now, let's mount an image.  Make sure to explain that this is a Podman feature.
# One use case for mounting another image into a container is security scanning.
# We can make use of the additional security from running a container and yet
# mount another image.
run_command podman run -it --rm --mount type=image,src=$IMAGE,dst=/image $IMAGE sh
clear
