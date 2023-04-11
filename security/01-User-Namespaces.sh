#!/usr/bin/env sh

source helpers.bash

setup
run_podman_no_prompt_root pull busybox

clear
run_command id
run_podman run --rm $IMAGE id -u

tempdir=$(mktemp -d)
tempfile=$tempdir/tutorial.txt
echo tutorial > $tempfile

run_podman_root run --uidmap=0:100000:5000 --rm -v $tempfile:/tutorial busybox ls -l /tutorial
run_command ls -l $tempfile
