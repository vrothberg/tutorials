#!/usr/bin/env sh

source helpers.bash

setup
archive=$(mktemp -d)

# Display skopeo's help message and explain that it's the "Swiss Army Knive"
# for working with container images.
run_command skopeo --help | head -n19
clear

# Show how to copy an image and explode it on the filesystem such that we can
# inspect the local OCI image a bit further.
run_command skopeo copy docker://registry.fedoraproject.org/fedora@sha256:e9b9d4ae36aa1ee0ee7b4b7fc6f470e24e3b473ac2cfb9c1abde2b8fb2500b99 oci:$archive
clear

# Show how the "raw" manifest looks like. Need some hacky workaround with `jq`
# as `--raw` does not pretty print.
run_command skopeo inspect --raw oci:$archive | jq .
prompt ""
clear

# Inspect the config and explain that it's being used to control some aspects
# of how the container will be run.  This way developers and vendors have some
# control over how the containers run.
run_command skopeo inspect --config oci:$archive
clear

# Display the tree of the local OCI image bundle.
# Explain that there's an index which allows for storing multiple images (e.g.,
# for multi arch).
run_command tree $archive
clear

# List the file types of the blobs.  The JSON files are manifests and configs.
# The compressed files are layers.
run_command file -b $archive/blobs/sha256/*
clear

# Now untar the layer, list the root and cat a file. Elaborate on a very high
# level that the manifest is used to pull the image, the config is used to help
# run the container, and the layers are mounted on top of eachother.  All of
# that is eventually converted into a "runtime bundle" that container runtimes
# use to finally run the container.
rootfs=$archive/rootfs
mkdir $rootfs
run_command tar -xf $archive/blobs/sha256/62946078034b7fe37984579d9b82ccf20cc98ffcd6517cf79ffad18e06fe2b23 -C $rootfs

run_command ls $rootfs

run_command cat $rootfs/etc/os-release

# Clean up in a user namespace so we can remove "root" files.
podman unshare rm -rf $rootfs
