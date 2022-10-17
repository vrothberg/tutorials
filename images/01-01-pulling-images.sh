#!/usr/bin/env sh

source helpers.bash

cleanup
clear

# First pull an image with a fully-qualified image reference.
# Elaborate on the format of a reference, namely
#  * The mandatory domain
#  * One or more optional namespaces/repositories
#  * The mandatory name
#  * The optional tag/digest which defaults to "latest"
run_podman pull registry.access.redhat.com/ubi9:latest
clear

# Now pull an image by digest.  Elaborate on the (security) benefits of pulling
# by digest (i.e., you get what you asked for).
run_podman pull registry.access.redhat.com/ubi9@sha256:a5c120f83beb00653c544c7b1d240140a3bf47705be50cb1cfb86a4dd587c2f2
clear

# Now pull by short-name and explain the difference to Docker which resolves to docker.io only.
run_podman pull ubi9:9.0.0

# Open the shortnames.conf and highlight the cross-vendor/distro collaboration.
run_command less /etc/containers/registries.conf.d/000-shortnames.conf
clear

# Last but not least show that pulling more than one image works as well.
run_podman pull ubi9:9.0.0 alpine:latest busybox:latest
