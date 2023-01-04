#!/usr/bin/env sh

source helpers.bash

cleanup
# pre-pull the image to speed things up during the demo
run_podman_no_prompt pull $SOURCE_IMAGE
clear

imagename="image:tutorial"

# Until now, we have been focusing on running containers, how to manage images
# in the local storage and how to pull them from a registry. Without a doubt,
# these are crucial skills for working with containers. Yet, everything starts
# with building containers, or "container images" to be more precise.
#
# Please note that this tutorial only scratches at the surface of what's
# possible with Dockerfiles.  It is meant as a short introduction and to give
# pointers to further resources.
#
# The most common way to build container images is via so-called Dockerfiles,
# also referred to as "Containerfiles".  Each line in a Dockerfile is a new
# directive or instruction. For instance, the `RUN` directive instructs to
# execute the specified command inside the build container.  A common command
# to execute in a build container is to install one or more packages that we
# want to use for either running or building the container.

# OK, let's get our hands dirty and start with a very simple Dockerfile.
containerfile=$(mktemp --suffix ".Dockerfile")
cat >$containerfile <<EOF
FROM $SOURCE_IMAGE
RUN dnf install -y vim
EOF

# The Dockerfile uses UBI9 as the base image and installs vim inside.
run_command cat $containerfile
clear

# You can build the image via `podman build`:
#  * --no-cache instructs Podman to ignore the build cache
#  *         -f points Podman to the Dockerfile
#  *         -t assigns a tag to the newly built image
run_podman build --no-cache -f $containerfile -t $imagename
clear

# We can now see two images.  The newly built one and the base image we used
# for building that image.
run_podman images

# `podman image tree` can come in handy to analyze an image, its dependencies
# and also its layers.
run_podman image tree $imagename
clear

# Highlight the man page, and mention that both, Red Hat and Docker, have great
# documentation on building containers.
run_command man containerfile
