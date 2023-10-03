#!/usr/bin/env sh

source helpers.bash

setup

name="tutorial" # Name of the container
tmpdir=$(mktemp -d)
containers_conf=$tmpdir/containers.conf

cat >$containers_conf <<EOF
[CONTAINERS]
default_capabilities = [
      "CHOWN",
      "DAC_OVERRIDE",
      "FOWNER",
      "FSETID",
      "KILL",
      "NET_BIND_SERVICE",
      "SETFCAP",
      "SETGID",
      "SETPCAP",
      "SETUID",
      "SYS_CHROOT",
]
env=["CONTAINERS_CONF=$containers_conf"]
EOF

# Motivating example:
#
# Some workloads require a large amount of flags and options on the CLI. The UX
# is not the best since it's cumbersome and very prone to errors to either
# forget certain flags or misspell them.  Only using the short names of flags
# lacks context and expressiveness.
run_command $PODMAN run --rm --cap-add=CHOWN --cap-add=DAC_OVERRIDE --cap-add=FOWNER --cap-add=FSETID --cap-add=KILL --cap-add=NET_BIND_SERVICE --cap-add=SETFCAP --cap-add=SETGID --cap-add=SETPCAP --cap-add=SETUID --cap-add=SYS_CHROOT $IMAGE true
clear

# CONTAINERS_CONF files _can_ help for some use cases but are not a generic
# solution. While there are drop-in configs in the .d directories, those are
# _always_ loaded and cannot be enabled on demand.  The only way to load them
# on-demand (so far) is to specify a file via an environment variable.
run_command eval CONTAINERS_CONF=$containers_conf $PODMAN run --rm $IMAGE printenv
clear

run_command cat $containers_conf
clear

# Starting with Podman 4.7, we can make use of the new --module flag.  The
# arguments to this flag can be absolute paths and relative paths.  Absolute
# paths are loaded as is while relative paths are resolved relative to the
# system and user "module paths".
#
# The equivalent to specifying CONTAINERS_CONF=xxx is --module=xxx.
run_command $PODMAN --module=$containers_conf run --rm $IMAGE printenv
clear

mkdir -p $HOME/.config/containers/containers.conf.modules
run_command eval mv $containers_conf $HOME/.config/containers/containers.conf.modules/capabilities.conf
run_command $PODMAN --module=capabilities.conf run --rm $IMAGE printenv
clear
