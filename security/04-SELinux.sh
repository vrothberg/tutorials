#!/usr/bin/env sh

source helpers.bash

setup
build_image_root
clear

# SELinux is a very powerful security mechanism of Linux.  On a high level,
# SELinux defines access controls for applications, processes and files on a
# Linux system.  It uses so-called policies comprising a set of rules
# determining what can or cannot be accessed.
#
# Underneath, SELinux uses a complex labeling and type enforcement which vastly
# exceeds my domain of expertise.  But since this tutorial focuses on
# containers and container security, we don't need to dive into the internals
# of SELinux; a few practical tips to deal with SELinux will help most users,
# especially when dealing with rootless containers.
#
# A classic SELinux issue when dealing with Podman is that a container isn't
# allowed to write to a volume.  Let's take this scenario as an example in this
# tutorial and discuss how to analyze and resolve it:

tmp=$(mktemp -d)
args="--rm -v $tmp:/data $IMAGE touch /data/file"

run_podman run $args

run_podman_root run $args
clear

run_podman run --privileged $args

run_podman run --security-opt=label=disable $args

run_podman run $args
clear

run_command_root ausearch -m avc -ts recent
clear

run_podman run --rm -v $tmp:/data:Z $IMAGE touch /data/file

run_podman run $args
clear

rm -rf $tmp
