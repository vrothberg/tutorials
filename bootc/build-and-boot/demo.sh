#!/usr/bin/env sh

source helpers.bash

image="quay.io/vrothberg/build-and-boot:bootc"

clear
prompt "Hands on: bootable containers."

clear
prompt "Example scenario: Build and boot a bootable container and ship an update."
echo ""

prompt "A simple Dockerfile based on fedora-bootc:"

run_command nvim bootc/build-and-boot/Dockerfile
clear

run_command podman build -t $image bootc/build-and-boot
clear

run_command podman images $image
clear

prompt "Let's use podman-bootc to run it in a VM!"
clear

prompt "Let's pretend we need to push an urgent update!"

run_command nvim bootc/build-and-boot/Dockerfile.fix
clear

run_command podman build -t $image -f bootc/build-and-boot/Dockerfile.fix
clear

prompt "Now we can push the update to the registry!"
run_command podman push $image
clear

prompt "Let's update the VM!"
clear

prompt "And finally, let's rollback!"
clear
