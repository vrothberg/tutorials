#!/usr/bin/env sh

source helpers.bash

cleanup
clear

# Running systemd inside a container is a longstanding desire in the container
# world.  Early on in the lifetime of Docker, the community attempted to add
# supported for running systemd inside a container but no pull request had been
# merged.
# 
# Unfortunately, there was no consensus upstream and a surprising amount of
# push back.  The immediate consequence was that many users had to write their
# own init scripts to run containerized workloads.  They also had to take care
# of process management such as reaping zombies and other tasks that modern
# init system take care of.
#
# Another unfortunate consequence of not being able to run systemd inside a
# container was that many packages actually require systemd.  For instance,
# httpd ships with a systemd service.  For further details, please refer to a
# great summary provided on LWN (https://lwn.net/Articles/676831/).
#
# The good news is that Podman supports running systemd inside a container as
# we shall explore in this tutorial.


