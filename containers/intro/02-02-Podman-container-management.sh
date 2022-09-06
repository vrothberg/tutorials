#!/usr/bin/env sh

source helpers.bash

setup

name="tutorial" # Name of the container

# Display the container sub-commands and talk on a high-level which commands exists and what they do.
run_command podman container --help
clear

# Create a named container
run_command podman create --replace --name $name $IMAGE sleep infinity

# Start the container
run_command podman start $name
clear

# Podman ps to list running containers
run_command podman ps --help
run_command podman ps
clear

# Attach to the container
run_command podman exec --interactive --tty $name sh
clear

# Podman top to list running processes inside a container
run_command podman top $name
clear

# Inspect a container and show some of the fields and how to navigate the JSON output
prompt "\$ podman inspect $name"
podman inspect $name | less
clear

# Now stop and remove the container
run_command podman stop -t3 $name

run_command podman ps --all

run_command podman rm $name

run_command podman ps --all
