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

# Elaborate on the currently being implemented vision of lifting K8s YAML to
# THE defacto standard of declaring containerized workloads.
# It's being used in OpenShift, Ansible, Podman, Edge, Automotive, systemd, etc.
run_command eog ./kube/data/kube-everywhere.png
clear

# Open the support matrix upstream.  Mention that documentation is continuously
# being improved.
run_command firefox --new-window https://github.com/containers/podman/blob/main/docs/kubernetes_support.md
clear
