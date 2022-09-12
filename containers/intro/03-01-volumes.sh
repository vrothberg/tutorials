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

# First, show the temp directory.
run_command tree $tmp

run_command cat $tmp/*
clear

# Second, show how to bind mount the directory into a container.
run_command podman run --rm --volume $tmp:/test $IMAGE cat /test/2
clear

# Now, show how to use named volumes.
run_command podman run --volume tutorial:/test --rm -it $IMAGE sh
clear

run_command podman volume ls

run_command podman volume inspect tutorial

volumeSource=$(podman volume inspect tutorial --format "{{.Mountpoint}}")
run_command cat $volumeSource/*

# Finally, elaborate on volume options.
# Mount the volume read-only and show a bit what that means and explain
# when it may be useful.
run_command podman run --volume $tmp:/test:ro --rm -it $IMAGE sh

rm -rf $tmp
