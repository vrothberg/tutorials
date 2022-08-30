#!/usr/bin/env sh

source helpers.bash

setup
archive=$(mktemp -d)

run_command skopeo --help
clear

run_command skopeo copy docker://registry.fedoraproject.org/fedora@sha256:e9b9d4ae36aa1ee0ee7b4b7fc6f470e24e3b473ac2cfb9c1abde2b8fb2500b99 oci:$archive
clear

run_command skopeo inspect oci:$archive
clear

run_command skopeo inspect --config oci:$archive
clear

run_command tree $archive
clear

run_command file -f $archive/* $archive/blobs/sha256/*
clear

rootfs=$archive/rootfs
mkdir $rootfs
run_command tar -xf $archive/blobs/sha256/62946078034b7fe37984579d9b82ccf20cc98ffcd6517cf79ffad18e06fe2b23 -C $rootfs

run_command ls $rootfs

run_command cat $rootfs/etc/os-release
