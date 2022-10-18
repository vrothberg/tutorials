#!/usr/bin/env sh

source helpers.bash

setup

# Pull a number of images so we have something work with
run_podman_no_prompt pull fedora:37 centos:9 alpine:latest busybox:latest
clear

# Start off with showing the `podman image --help` message. As for containers,
# there are quite some image-related commands to perform all kinds of
# operations. In this session, we want to focus on management tasks such as
# listing, inspecting, searching, removing.

# `images` is an alias for `image list`
run_podman images
clear

# --all will also display intermediate images from building
run_podman images --all
clear

# Briefly mention that --sort can come in handy
run_podman images --sort=size
clear

# Now show `podman image inspect` and run through the fields.
prompt "\$ podman image inspect $IMAGE"
$PODMAN image inspect $IMAGE | less
clear

# Mention that --format integrates well into automation
run_podman image inspect $IMAGE --format "{{.Digest}}"
clear

# Let's remove some images now.
run_podman image rm fedora:37
clear

# Elaborate on -f/--force
run_podman run -d --rm -t=0 $IMAGE sleep infinity
run_podman rmi $IMAGE
run_podman rmi --force $IMAGE
clear

# Now --all
run_podman rmi --all --force
clear

# --ignore can be helpful in automation when we just want to make sure that a
# given image is gone
run_podman rmi foo:bar
run_podman rmi --ignore foo:bar
