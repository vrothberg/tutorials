#!/usr/bin/env sh

source helpers.bash

run_command man capabilities
clear

dockerfile=$(mktemp --suffix ".Dockerfile")
cat >$dockerfile <<EOF
FROM fedora:37
RUN  mknod /dev/mynull c 1 3
EOF

run_command cat $dockerfile

run_podman_root build --no-cache -f $dockerfile
clear

run_podman_root build --no-cache -f $dockerfile --cap-add=all
clear

run_podman_root build --no-cache -f $dockerfile --cap-add=MKNOD
clear
