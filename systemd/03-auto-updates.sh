#!/usr/bin/env sh

source helpers.bash

setup

# Make sure the quadlet path is present in the home directory.
QUADLETPATH=$HOME/.config/containers/systemd
run_command_no_prompt mkdir -p $QUADLETPATH

UNITNAME=tutorial.container
UNITPATH=$QUADLETPATH/$UNITNAME

run_command_no_prompt rm -rf $UNITPATH
run_command_no_prompt systemctl --user stop $UNITPATH
run_command_no_prompt systemctl --user reset-failed
run_command_no_prompt systemctl --user daemon-reload
run_command_no_prompt systemctl --user reset-failed
run_podman_no_prompt rm -af -t0

# Run a local registry to allow for testing auto-updates.
CONF=$HOME/.config/containers/registries.conf
rm -f $CONF

REGIMG=localhost:5000/tutorial/image:latest
run_podman_no_prompt pull alpine:3.7 alpine:3.8 registry:2
run_podman_no_prompt run -d -p 5000:5000 registry:2

cat >$CONF <<EOF
[[registry]]
location="localhost:5000"
insecure=true
EOF
run_podman_no_prompt push alpine:3.7 $REGIMG
clear

# OK, let's get our hands dirty and start with a very simple .container file.
cat >$UNITPATH <<EOF
[Container]
Image=$REGIMG
Exec=top
AutoUpdate=registry
ContainerName=tutorial
EOF

# Open the .container file and explain the idea of auto updates.
run_command vi $UNITPATH
clear

# Start the Quadlet service.
run_command systemctl --user daemon-reload
run_command systemctl --user start tutorial.service
run_command systemctl --user status tutorial.service
clear

# Show that the container is really running.
run_podman ps
clear

# Run `podman auto-update` and elaborate a bit on the output.
run_podman auto-update
clear

# Now update the image on registry.
run_podman push alpine:3.8 $REGIMG
clear

run_podman auto-update
clear

run_podman ps

run_command systemctl --user stop tutorial.service
rm -f $CONF
