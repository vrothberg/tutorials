#!/usr/bin/env sh

source helpers.bash

setup

# Make sure the quadlet path is present in the home directory.
QUADLETPATH=$HOME/.config/containers/systemd
run_command_no_prompt mkdir -p $QUADLETPATH

UNITNAME=tutorial.container
UNITPATH=$QUADLETPATH/$UNITNAME
rm -f $QUADLETPATH/tutorial.*

run_command_no_prompt systemctl --user stop $UNITPATH
run_command_no_prompt systemctl --user reset-failed
run_command_no_prompt rm -rf $UNITPATH
run_command_no_prompt systemctl --user daemon-reload
run_command_no_prompt systemctl --user reset-failed
run_podman_no_prompt rm -af -t0
clear

# Podman 4.4 ships with a new way of containerizing systemd services. It's a
# declarative approach similar to Compose or K8s YAMl that allows you to write
# a containerized service once and deploy it anywhere.
#
# Quadlet is a huge improvement:
#  * The workflow is much improved over podman-generate-systemd
#  * The units/service do not have to be manually regenerated with a Podman update
#  * The complexities of the generated units are entirelly hidden from the user
#  * It enables a marketplace-like experience as the community can share files
#  * It supports containers, volumes, networks and K8s deployments
#
#  Note that this tutorial is meant to give an idea of Quadlet and does not aim
#  for completeness.  Plese refer to the docs for a detailed reference of
#  Quadlet.

# Let's first give a quick example of using podman-generate-systemd.  That will
# help the user understand the problem space and how much of an improvement
# Quadlet really is.

run_podman create --name=tutorial $IMAGE
clear

# Short comings:
#  * Complicated workflow to first create a container, then generate the unit, then install the unit
#  * Update issue: workflow has to be repeated to consume bug fixes after an update
#  * Users are subjected to the complexities 
run_podman generate systemd --new tutorial
clear

# OK, let's get our hands dirty and start with a very simple .container file.
cat >$UNITPATH <<EOF
[Container]
Image=$IMAGE
Exec=sleep infinity
Label=CreatedBy=Quadlet
ContainerName=tutorial
PodmanArgs=--stop-timeout=0

[Service]
Restart=on-failure
EOF

# Open the .container file and explain the idea of Quadlet.
run_command less $UNITPATH
clear

# Reloading the daemon will fire the systemd generators.
# Quadlet is, in fact, a systemd generator, find the new file and create
# service for it.
run_command systemctl --user daemon-reload
# The service has the same name as the $NAME.container file.
run_command systemctl --user status tutorial.service
# Now start the service, clear and show the status again.
run_command systemctl --user start tutorial.service
clear
run_command systemctl --user status tutorial.service
clear

# Now show that the container is really running and that systemd will take of
# restarting the service on failure (just as specified in the .container file
# above).
run_podman ps
run_podman kill tutorial
run_podman ps
clear

# Show again the Quadlet file and point to the on-failure restart policy.
# That's a nice occasion to elaborate on exit-code propagation from the
# container to conmon to systemd and conmon being the main PID.
run_command less $UNITPATH
clear

# Now stop the service.  Mention that sleep ignores SIGTERM, so Podman will
# wait 10 seconds by default until killing a container.  The delayed service
# stop is a common source of surprise to users but it's really the same
# behaviour outside of systemd.
run_command systemctl --user stop tutorial.service

# Last, point the user to the systemd unit.
run_command man podman-systemd.unit
