#!/usr/bin/env sh

source helpers.bash

# Create a temporary directory that we can mount into the container
tmp=$(mktemp -d)

run_podman run -v $tmp:/data fedora:37 touch /data/content

# Quick check: run with --privileged to confirm it's a security issue
run_podman run --privileged -v $tmp:/data fedora:37 touch /data/content
clear

# We're using a volume so it's very likely SELinux.
# Disable it for a quick check.
run_podman run --security-opt=label=disable -v $tmp:/data fedora:37 touch /data/content
clear

# Also show ausearch
run_podman run -v $tmp:/data fedora:37 touch /data/content

run_command_root ausearch -m avc -ts recent

run_podman run -v $tmp:/data:Z fedora:37 touch /data/content
clear

# Mention apparmor for those using it
run_podman run --security-opt apparmor=unconfined -v $tmp:/data:Z fedora:37 touch /data/content

# Clean up if possible
rm -rf tmp
