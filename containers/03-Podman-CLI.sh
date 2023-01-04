#!/usr/bin/env sh

source helpers.bash

setup

# Require evince to display PDF files.
require_tool evince


# Show the `container --help` and sub-commands of Docker and Podman.
# Mention that
#  * Docker made containers popular and successful
#  * Many users (including the Podman developers) have already been accustomed to the Docker CLI
#  * Podman is CLI compatible to Docker but added a number of new commands
#  * The architecture of the two tools is very different

run_command podman --help
clear

run_command podman container --help
clear

run_command sudo docker container --help
clear

# Some distributions such as Fedora ship a `podman-docker` package.
# There will still be a `docker` executable in the $PATH but it will actually point to Podman.
# This way, the migration from Docker to Podman is effortless.
run_command sudo dnf info podman-docker
clear

# Show some more podman commands and explain the command structure.
# Sub-commands are usually structured by "objects" such as `podman {image,container,pod} $command`.
run_command podman image --help
clear

# Some commands have top-level aliases.  Those are usually the "hot" ones and used more frequently than others.
run_podman podman pull --help
clear

# Show a PDF illustrating the architectural differences between Docker and Podman
run_command evince ./containers/data/02-01-architecture-comparision.pdf
