#!/usr/bin/env sh

source helpers.bash

CONF=$HOME/.config/containers/registries.conf

cleanup
rm -f $CONF
run_podman_no_prompt pull docker.io/registry:2
clear

# In this tutorial, I want to talk about registry mirrors. Using mirrors to
# pull images from another, most likely internal registry, is a common use
# case. Production systems may run in an air-gapped environment where mirrors
# can be used to avoid pulling from registries outside the network which
# wouldn't work. But you may also need it on your workstation since Docker Hub
# is rate limited.  A local mirror caching images from Docker Hub to reduce
# traffic and hence avoid a rate limit is certainly helpful to me.
#
# OK, let's start a local mirror and configure registries.conf accordingly.
run_podman run -d -p 5000:5000 -e REGISTRY_PROXY_REMOTEURL="https://quay.io" registry:2
clear

run_podman pull localhost:5000/libpod/busybox
clear

cat >$CONF <<EOF
[[registry]]
location="quay.io"

[[registry.mirror]]
location="localhost:5000"
insecure=true
EOF

run_command cat $CONF
clear

run_podman --debug pull quay.io/libpod/busybox
clear

run_command man containers-registries.conf
