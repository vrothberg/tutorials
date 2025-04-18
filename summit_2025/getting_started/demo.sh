#!/usr/bin/env sh

source helpers.bash

image="${IMAGE:-quay.io/vrothberg/bootc:demo}"
dir=$(dirname ${BASH_SOURCE[0]})

clear
prompt "Hands on: bootable containers."

clear
prompt "Example scenario: Build and boot a bootable container and ship an update."
echo ""

prompt "A simple Containerfile based on centos-bootc:stream10"

run_command nvim $dir/Containerfile
clear

run_command podman build -t $image -f $dir/Containerfile
clear

run_command podman images $image
clear

prompt "Let's use podman-bootc to run it in a VM!"
clear

prompt "Let's fix the bug and update our VM!"

run_command nvim $dir/Containerfile.fix
clear

run_command podman build -t $image -f $dir/Containerfile.fix
clear

prompt "Now we can push the update to the registry!"
run_command podman push $image
clear

prompt "Let's update the VM!"
clear

prompt "And finally, let's rollback!"
clear
