#!/usr/bin/env sh

source helpers.bash

cleanup
clear

# * Podman intends on bridging local development with the "cloud-native" orchestrated world.
# * You may be testing things locally on the workstations before deploying to a cluster.
# * K8s YAML can replace Docker Compose (more open and community/standards driven)

kubefile=$(mktemp --suffix ".yaml")
cat >$kubefile <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: tutorial-pod
spec:
  containers:
  - command:
    - top
    image: alpine
    name: tutorial
EOF

# Show a simple Kubernetes YAML
run_command cat $kubefile
clear

# Run it and show the created/running pod and container(s)
run_podman kube play $kubefile
clear

run_podman pod ps
run_podman ps
clear

# Show how to clean up a deployment.  Also mention the --replace flag for `kube
# play`.
run_podman kube down $kubefile
clear

run_podman pod ps
run_podman ps
clear

run_command man podman-kube-play
clear
