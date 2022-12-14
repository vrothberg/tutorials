#!/usr/bin/env sh

source helpers.bash

CONF=$HOME/.config/containers/registries.conf
REGIMG=localhost:5000/tutorial/image:latest

cleanup
rm -f $CONF
run_podman_no_prompt pull fedora
touch $CONF
clear

# This tutorial is meant to explain the basics of containers-registries.conf(5).
#
# The use case is to first run a registry on localhost and configuring it so we
# can use it without TLS verification - I am lazy and don't want to create and
# manage certificates.
#
# After that we want to redirect all docker.io traffic to this very registry.

# OK, let's run the local registry and make the push fail - TLS!
run_podman run -d -p 5000:5000 docker.io/registry:2
clear

run_podman push fedora $REGIMG

run_podman push --tls-verify=false fedora $REGIMG
clear

# While we can, in theory, add the --tls-verify flag, it rarely works in
# practice.  Existing code cannot be changed that easily, so it would be
# nice to just transparently mark the registry as insecure.

cat >$CONF <<EOF
[[registry]]
location="localhost:5000"
insecure=true
EOF

run_command cat $CONF
run_podman push fedora $REGIMG
clear

# Let's now show how to "rewrite" reference by using prefixes. The use case
# here is to use the registry running on localhost instead of docker.io.  We
# may be running in an air-gapped environment or we just have a local cache to
# avoid running into Docker Hub's rate limits.

cat >$CONF <<EOF
[[registry]]
prefix="docker.io"
location="localhost:5000"
insecure=true
EOF

run_command cat $CONF
run_podman pull docker.io/tutorial/image:latest
run_skopeo inspect docker://docker.io/tutorial/image:latest
