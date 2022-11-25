#!/usr/bin/env sh

source helpers.bash

#cleanup

# Pre-fetch the golang image to not waste time during the demo
GO_IMAGE=docker.io/golang:1.19
run_podman_no_prompt pull $GO_IMAGE


# This tutorial is mostly food for thought for users new to building container
# images. We shall build an image with a Go binary and show how much space we
# can safe by using a multi-stage build.
#
# This should give the audience a _feeling_ for the problem space.  It is not
# meant to be a comprehensive tutorial on how to build small images which would
# be a course on its own.
#
# Some pointers for further reading is meant to get the audience working
# independently and to continue the learning experience.

imagename="hello-podman"
containerfile=$(mktemp --suffix ".Dockerfile")
cat >$containerfile <<EOF
FROM $GO_IMAGE
WORKDIR /hello
RUN ls
RUN pwd
RUN go build -o /bin/hello-podman hello.go
EOF

clear

run_command cat builds/hello/hello.go
run_command cat $containerfile
clear

run_podman build -v $(pwd)/builds/hello:/hello:Z -f $containerfile -t $imagename:simple
clear

run_podman run --rm $imagename:simple /bin/hello-podman
run_podman images
clear

cat >$containerfile <<EOF
FROM $GO_IMAGE as build-stage
WORKDIR /hello
RUN ls
RUN pwd
RUN go build -o /bin/hello-podman hello.go

FROM scratch
COPY --from=build-stage /bin/hello-podman /bin/hello-podman
EOF

run_command cat $containerfile
clear

run_podman build -v $(pwd)/builds/hello:/hello:Z -f $containerfile -t $imagename:minimal
clear

run_podman run --rm $imagename:simple /bin/hello-podman
run_podman images
clear

echo_bold "-> redhat.com/sysadmin/tiny-containers"
echo_bold "-> Nicholas Dille: dille.name"
echo_bold "-> docs.docker.com/engine/reference/builder/"
read -p ""
