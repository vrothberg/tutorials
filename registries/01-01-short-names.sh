#!/usr/bin/env sh

source helpers.bash

cleanup
rm -f $HOME/.cache/containers/short-name-aliases.conf
run_command_root_no_prompt docker rmi -f fedora
clear

# Introduce the audience to short names and how Docker and Podman resolve them.

# Docker resolves short names always to docker.io.  Docker controls the
# container engine and the registry and has an understandable desire to bind
# users to their products as much as possible.  Docker Hub is a great product
# and a way to monetize.
run_command_root docker pull fedora
clear

# Podman can resolve short names in a number of ways.  Via a list of registries
# and via aliases.
#
# But let's start with the "unqualified-search-registries" in
# containers-registries.conf(5). This list of registries is consulted when
# pulling an image via a short name that has no matching aliases which we will
# discuss later on.
run_podman pull nginx
clear

# Show the registries.conf and explain the search registries a bit more.
run_command less /etc/containers/registries.conf
clear

# Now explain aliases.
run_podman pull fedora

# Last but not least:
# * Elaborate on the ambiguity of short names
# * But even FQNs with tags _may_ be ambiguous (e.g., when using mirrors)
# * The "get what you asked for" is using digests
run_podman pull registry.fedoraproject.org/fedora@sha256:ce08a91085403ecbc637eb2a96bd3554d75537871a12a14030b89243501050f2
