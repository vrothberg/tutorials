#!/usr/bin/env sh

source helpers.bash

setup

name="tutorial" # Name of the container

# Start a container that sleeps until infinity. We will use the container below
# to illustrate on a high level what a Linux container is.
run_command podman run --detach --rm --replace --name $name $IMAGE sleep infinity

# First command is `ps` to show that we can only see processes running inside
# the container but do not have any knowledge about what's happening outside.
# Explain what a PID namespace is.
run_command podman exec $name ps
clear

# Show that the default user is root for portability's sake: many tools such as
# package managers need to run as root.
run_command podman exec $name whoami

# Show that we can run containers with "root" processes inside while being an
# ordinary non-root user on the host. Explain what a user namespace is.
run_command whoami

# Use `podman top` to give a nice overview of the PID and user namespace.
run_command podman top $name user,huser,pid,hpid
clear

# Finally, explain that we can run any Linux distribution (or container in
# general) independent of the host system.

# Show what's running inside the container.
run_command podman exec $name cat /etc/os-release | head -n2

# Show what's running on the host.
run_command cat /etc/os-release | head -n2
