#!/usr/bin/env sh

source helpers.bash

setup
name="tutorial"

# Need the busybox image for root{ful,less}
run_podman_no_prompt pull busybox
run_podman_no_prompt_root pull busybox
clear

# This tutorial focuses on rootless containers and common pitfalls when using them.  The previous one already elaborated on the differences between rootless and rootful containers, so let's dive right into it.

# User namespaces
#
# Podman employs user namespaces for running rootless containers.  A user namespaces isolates "security-related identifiers and attributes, in particular, user IDs and group IDs (see credentials(7)), the root directory, keys(see keyrings(7)), and capabilities (see capabilities(7))."
#
# What's most important for us to understand is the UID and GID mapping that is configured in `/etc/sub{g,u}id`.

# Show the configured mappings.
run_command cat /etc/subuid /etc/subgid

# Show how the above mappings translate into the user namespace.
run_podman unshare cat /proc/self/uid_map
clear


# Illustrate the ID mapping via the --user flag of Podman.
run_podman run --user=0  --rm -d --replace --name=$name $IMAGE sleep infinity
run_podman top $name huser,user
clear

# Now a mapping for user 20.  Remember, computers start counting a 0.
run_podman kill $name
run_podman run --user=20 --rm -d --replace --name=$name $IMAGE sleep infinity
run_podman exec $name cat /proc/self/uid_map
run_podman top $name huser,user
clear

# Now with mapping the user ID into the container.
run_podman kill $name
run_podman run --userns=keep-id --rm -d --replace --name=$name $IMAGE sleep infinity
run_podman top $name huser,user
clear


# Now mention the most common user issue with rootless container: mounts and EPERMs
tmp=$(mktemp -d -p .)
echo 123 > $tmp/123
run_command ls -la $tmp

# Get the EPERM
run_podman run --user 1000:1000 -v $tmp:/data:z --rm busybox cat /data/123

run_podman_root run -v $tmp:/data:Z --rm busybox cat /data/123

run_podman run --userns=keep-id -v $tmp:/data:Z --rm busybox cat /data/123

rm -rf $tmp
