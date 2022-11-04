#!/usr/bin/env sh

source helpers.bash
clear

# Skopeo is like a Swiss army knife for container images. It was built for
# inspecting container images on the registry without having to pull it down.
# Since then, it grew into a powerful tool to manage container images.

# Show the main help message to give an impression of what Skopeo can do.
run_command skopeo --help|head -n20
clear

# Show a simple remote inspect
cmd="skopeo inspect docker://$SOURCE_IMAGE"
prompt "\$ $cmd"
$cmd | less
clear

# Show the --raw flag
cmd="skopeo inspect --raw docker://$SOURCE_IMAGE"
prompt "\$ $cmd"
$cmd | jq . | less
clear

# Show the --config flag
cmd="skopeo inspect --config docker://$SOURCE_IMAGE"
prompt "\$ $cmd"
$cmd | jq . | less
clear
