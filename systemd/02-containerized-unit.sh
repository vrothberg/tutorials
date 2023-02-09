#!/usr/bin/env sh

source helpers.bash

setup

# Make sure systemd/user is present in the home directory.
SYSTEMDPATH=$HOME/.config/systemd/user
mkdir -p $SYSTEMDPATH

UNITNAME=tutorial.service
UNITPATH=$SYSTEMDPATH/$UNITNAME

run_command_no_prompt systemctl --user stop $UNITNAME
run_podman_no_prompt rm -f -t0 tutorial
clear

# Podman makes running containerized systemd units easy. The architecture of
# Podman integrates into systemd much better than Docker or other daemonized
# container engines.  The beauty of Podman is its simplicity and that the
# container is a child process of the initial Podman command.  Hence, the main
# PID of the systemd service will be set to `conmon` the small container
# monitor that is being started before and removed after the container.
# 
# Let's not go into all these details but if you are curious, please refer to
# the large number of blogs out there on running Podman inside of systemd.  You
# may just google "enable sysadmin podman systemd".
#
# This tutorial is just meant to be a short introduction and help get the
# audience started and continue exploring the space.  We start with a simple
# use case of moving an existing container into a systemd unit and continue to
# a brand new (Feb 08 '23) feature that has just been shipped with Podman 4.4,
# called Quadlet.  Quadlet will be addressed in the following tutorial.

# OK, let's start with a simple example.  We have a container running, do some
# testing and are happy and ready to go.
run_podman run -d --name=tutorial $IMAGE sleep infinity

# The container is running.
run_podman ps
clear

# Create a "simple" systemd unit and elaborate on the contents.
run_podman generate systemd tutorial > $UNITPATH
run_command less $UNITPATH
clear

# The recommended way though is to use the `--new` flag and create a unit that
# creates/removes containers on the fly.
run_podman generate systemd --new tutorial > $UNITPATH
run_command less $UNITPATH
clear

# Let's run the generate unit now.
run_command systemctl --user daemon-reload
run_podman rm -f -t0 tutorial
run_command systemctl --user start $UNITNAME
clear
run_podman ps
run_command systemctl --user status $UNITNAME
clear

# The `status` above will show "conmon" as the main PID.  To elaborate on that
# a bit, open the architecture PDF.
run_command evince ./containers/data/02-01-architecture-comparision.pdf
