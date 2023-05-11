#!/usr/bin/env sh

source helpers.bash

setup
run_podman_no_prompt rm -af
clear

# Since version 3.0, Podman ships with a Docker-compatible REST API to fulfill
# the promise of being a drop-in replacement for Docker.  But it also ships
# with a more feature-rich Podman-specific API which is also being used when
# running Podman on Windows and Mac OS, for instance, via Podman Desktop.
#
# The Podman-specific REST API is called the "libpod API" with "libpod" being
# the name for the internal backend of Podman (i.e., the library for Pods).

socket="$XDG_RUNTIME_DIR/podman/podman.sock"

# First, install the `podman-remote` binary which is a nice occasion to
# elaborate on `podman-remote` being the "client" to the Podman "server" on a
# Linux machine.  Since containers are inherently a Linux concept and
# technology, there must always be a Linux somewhere that we can run Podman and
# the containers on.
run_command_root dnf install -y podman-remote
clear

# Now run `podman --remote` and show that the Linux binary can act as a local
# Linux client, a local Linux server and as a remote client.  Pretty cool ;-)
run_podman --remote images
clear

# For sure, we can curl the libpod REST API as well.
run_podman --remote run --name=tutorial $IMAGE echo \"Via the remote client\"
run_command curl -XDELETE --unix-socket $socket http:/libpod/containers/tutorial
run_podman ps --all
clear

# Now show where to find the documentation for the REST API.  Just browse a bit
# through the docs and show how to navigate and interpret the data.
run_command firefox --new-window https://docs.podman.io/en/latest/_static/api.html?version=v4.5
clear

# Last, show the Podman Desktop website and talk about the Windows and Mac OS
# support.  There is a lot to explore and talk about.
run_command firefox --new-window https://podman-desktop.io
