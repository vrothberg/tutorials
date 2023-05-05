#!/usr/bin/env sh

source helpers.bash

setup
clear

# Podman has always aimed at being a drop-in replacement for Docker. Initially,
# Podman has focused on compatibility on the command line. Starting with
# version 3.0, Podman ships with a Docker-compatible REST API.
#
# The compatibility on the REST API allows for a smooth migration from Docker
# to Podman where existing scripts and tools just need to be pointed to the
# Podman socket.
#
# This tutorial elaborates a bit on the compatibility and shows some common
# practices and tips and tricks of how the REST API works and how to easily
# migrate from Docker to Podman.

# Let's start with a simple example of running Docker against the Podman socket.
# This should make it more obvious that/how compatible Podman is.  Make sure to
# mention that the podman.socket fires the podman.service systemd service which
# shuts down after 5 seconds without incoming traffic.

docker="DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock docker"

run_command systemctl --user start podman.socket
run_command eval "$docker" pull alpine
run_command eval $docker images
run_command eval $docker run --rm alpine echo \"I am running a Podman container with the Docker client\"
