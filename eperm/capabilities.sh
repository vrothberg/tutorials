#!/usr/bin/env sh

source helpers.bash
clear

run_command man capabilities
clear

dockerfile=$(mktemp --suffix ".Dockerfile")
cat >$dockerfile <<EOF
FROM $MINIMAGE
RUN  mknod /dev/mynull c 1 3
EOF

run_command cat $dockerfile

run_podman_root build --no-cache -f $dockerfile
clear

run_command_root setenforce 0
run_podman_root build --no-cache -f $dockerfile
run_command_root setenforce 1
clear


run_podman_root build --no-cache -f $dockerfile --cap-add=all
clear

run_command man capabilities
clear

run_podman_root build --no-cache -f $dockerfile --cap-add=MKNOD
clear
