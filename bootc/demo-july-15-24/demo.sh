#!/usr/bin/env sh

source helpers.bash

clear
prompt "Example scenario RHEL SST QEs will face going forward. Best practices to test on Image Mode?"
echo ""

prompt "Task: make sure the integration tests of github.com/vrothberg/vgrep pass in Image Mode."
echo ""

prompt "After a bit of fiddling, I ended up with the following Dockerfile:"


run_command nvim bootc/demo-july-15-24/Dockerfile
clear

run_command podman build -t vgrep:bootc bootc/demo-july-15-24/
clear


prompt "The user stories explicitly mentioned a local dev-test cycle with Podman and the OCI container before transitioning to an Image Mode host. So let's run the tests in a local Podman container:"
echo""
run_command podman run --detach --name=vgrep --replace vgrep:bootc

prompt "Running the container in --detached mode allows for systemd to be PID1 and initialize the bootc container as intended. We can now exec' into the container to get some work done:"
echo ""
run_command podman exec -it vgrep bash
clear

prompt "The next steps in the developer workflow have already been demoed:"
echo ""
prompt " * Use bootc-image-builder to convert and boot the disk image."
echo ""
prompt " * Use podman-bootc to automate the conversion and booting."
clear

prompt "Lessons learned ..."
echo ""
prompt " 1) Bootc images are OCI images with specific attributes users need to be familiar with. They do behave differently!"
echo ""
prompt " 2) When working locally, make sure to start the bootc container with systemd and then podman-exec into it. This makes sure the systemd services have fired."
echo ""
prompt " 3) The docs are great and contain all information but they are a bit scattered.  We need on-boarding docs and provide best practices."
echo ""
prompt " 4) Going forward, I want to pay more attention to the developer experience and enablement."
