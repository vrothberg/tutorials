#!/usr/bin/env sh

source helpers.bash

cleanup
run_podman_no_prompt pull $SOURCE_IMAGE
clear

imagename="buildah:image"

# Buildah is a tool for building container images. `podman build` is internally
# using Buildah's code.
# 
# Recycle the Dockerfile from the previous demo to explain the relationship
# between the two tools.
containerfile=$(mktemp --suffix ".Dockerfile")
cat >$containerfile <<EOF
FROM $SOURCE_IMAGE
RUN dnf install -y vim
EOF

# The Dockerfile uses UBI9 as the base image and installs vim inside.
run_command cat $containerfile
clear

# Run `buildah build` and state the obvious: Docker compatibility.
run_command buildah build --no-cache -f $containerfile -t $imagename
clear

# Explain that Buildah and Podman share the same building blocks and underlying
# libraries.  For instance, they share the same container and image storage.
run_podman images
run_command buildah images
clear

# Now it's time for Buildah-specific features: it's like Bash for container builds
ctrname="buildah-container"

# Create a "build container" and install skopeo in it.
run_command buildah from --name $ctrname $imagename
run_command buildah run $ctrname dnf install -y skopeo
clear

# Now run `ps` with Buildah and Podman and explain the concept of "external"
# containers in Podman.
run_podman rmi $imagename
run_podman ps
run_podman ps --external
run_command buildah ps
clear

# Finally, commit the image.
run_command buildah commit $ctrname localhost/buildah:image-v2
run_podman images
clear

echo_bold "-> www.buildah.io"
echo_bold "-> www.github.com/containers/buildah"
echo_bold "-> quay.io/buildah/stable"
read -p ""
