#!/usr/bin/env sh

source helpers.bash

INIT_IMG=ubi9-init run_podman_no_prompt rm -af -t0 run_podman_no_prompt pull
$INIT_IMG clear

# Running systemd inside a container is a longstanding desire in the container
# world.  Early on in the lifetime of Docker, the community attempted to add
# supported for running systemd inside a container but no pull request had been
# merged.
# 
# Unfortunately, there was no consensus upstream and a surprising amount of
# push back.  The immediate consequence was that many users had to write their
# own init scripts to run containerized workloads.  They also had to take care
# of process management such as reaping zombies and other tasks that modern
# init system take care of (and no user should worry about).
#
# Another unfortunate consequence of not being able to run systemd inside a
# container was that many packages actually require systemd.  For instance,
# httpd ships with a systemd service.  For further details, please refer to a
# great summary provided on LWN (https://lwn.net/Articles/676831/).
#
# The good news is that Podman supports running systemd inside a container as
# we shall explore in this tutorial.

# Let's start a ubi9-init container which ships with systemd pre-installed.
# Podman will automagically setup the container to make it comfortable for
# systemd.
run_podman run -d --name=tutorial $INIT_IMG

# List the process running inside the "systemd" container to show that systemd
# is really running inside.
run_podman top tutorial user,pid,comm
clear

# Get a shell into the container and play a bit.  You can run `ps`,
# `journalctl` and `systemctl status` to elaborate a bit on that it really just
# works.
run_podman exec -it tutorial bash
clear

# Now install `httpd` and run via `systemctl` to put the cherry on the cake.
run_podman exec tutorial dnf install -y httpd
clear
run_podman exec tutorial systemd start  httpd
run_podman exec tutorial systemd status httpd
clear

# Finally open the man page to explain the `--systemd` option and the various
# mounts Podman will set up for systemd to feel home.
run_command man podman-create
