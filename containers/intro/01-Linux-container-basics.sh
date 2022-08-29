#!/usr/bin/env sh

source helpers.bash

setup

name="tutorial" # Name of the container

run_command podman run --detach --rm --replace --name $name $IMAGE sleep infinity

run_command podman exec $name ps -ef

run_command podman exec $name whoami

run_command whoami

run_command podman top $name user,huser,pid,hpid

run_command podman exec $name cat /etc/os-release | head -n2

run_command cat /etc/os-release | head -n2
