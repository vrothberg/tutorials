#!/usr/bin/env sh

source helpers.bash

setup
run_podman_no_prompt_root pull busybox
run_podman_no_prompt_root rm -af -t0
clear

# User namespaces are at the core of (rootless) containers. User namespaces
# isolate security related attributes, in particular, user IDs and group IDs.
# A process's user and group IDs can be different inside and outside a user
# namespace.
#
# Let's explore, step by step, how Podman uses these namespaces!

# First show what an ordinary non-root user can run a container and become root
# inside the container:
run_command id
run_podman run --rm $IMAGE id
clear

# Now elaborate that container images need more than just one ID for mapping
# things into a user NS.  Think of a Linux distribution such as RHEL: the
# default file system will have more than just on user and group in /etc,
# /usr/, etc.  That means we are dealing with mapping entire ranges of
# user and group IDs.  And since these IDs are finite on the system and cannot
# overlap among users, they need to be manages in some way.
#
# Let's have a look at how a rootful container can make use it.  We're mounting
# a file created by host user and bind-mount it into the container.  We'll see
# that the owner/group will be displayed as "nobody".  This is because the ID
# (see `id -u`) is not known inside the user namespace.
tempdir=$(mktemp -d)
tempfile=$tempdir/tutorial.txt
echo tutorial > $tempfile

run_command ls -l $tempfile
run_podman_root run --uidmap=0:100000:5000 --name=tutorial -v $tempfile:/tutorial -d busybox sleep infinity

run_podman_root exec tutorial ls -l /tutorial
run_podman_root top tutorial user,huser,comm

# Now open the below PDF and explain how these ranges are centrally configured
# on the host.  Don't forget mentioning that modern versions of FreeIPA and
# LDAP allow for configuring them directly in the user records and do not
# require writing the mappings manually to /etc/sub*id.
run_command evince security/data/user_namespace_and_id_mappings.pdf
clear
