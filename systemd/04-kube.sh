#!/usr/bin/env sh

source helpers.bash

# Make sure the quadlet path is present in the home directory.
QUADLETPATH=$HOME/.config/containers/systemd
run_command_no_prompt mkdir -p $QUADLETPATH

UNITNAME=tutorial.kube
UNITPATH=$QUADLETPATH/$UNITNAME

run_command_no_prompt rm -rf $UNITPATH
run_command_no_prompt systemctl --user stop $UNITPATH
run_command_no_prompt systemctl --user reset-failed
run_command_no_prompt systemctl --user daemon-reload
run_command_no_prompt systemctl --user reset-failed
run_podman_no_prompt rm -af -t0
cleanup
clear

# At this point, we have had a look at Podman's Kubernetes support and systemd
# integration.  In this tutorial, we are marrying the two concepts and run
# Kubernetes workloads inside of systemd using Podman.
#
# You may ask "WHY?", so here's a short list:
#  * Running K8s locally has huge hardware requirements
#  * Using a K8s cluster is expensive
#  * K8s YAML is a defacto standard for declaring containerized workloads
#  * Podman allows for running K8s workloads on a small Raspberry Pi (3)
#  * Running this workload in systemd makes it more robust and integrates well into the system

# So let's get our hands dirty and run the exemplary K8s YAML below.
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

# First show the YAML file.
run_command cat $kubefile
clear

# There are two ways of running K8s workloads in systemd via Podman.
# The first one is by using the podman-kube@ systemd template.
# Article: https://www.redhat.com/sysadmin/kubernetes-workloads-podman-systemd

escaped=$(systemd-escape $kubefile)
prompt "\$ escaped=\$(systemd-escape \$kubefile)"

run_command systemctl --user start podman-kube@$escaped.service
clear
run_podman ps
clear
run_command systemctl --user stop podman-kube@$escaped.service
run_podman ps -a
clear

# The second way of running K8s workloads in systemd is Quadlet.
# Quadlet supports running containers and K8s workloads, so let's have a look:

cat >$UNITPATH <<EOF
[Unit]
Description=A simple .kube file for running K8s workloads

[Kube]
Yaml=$kubefile
EOF

run_command cat $UNITPATH
clear

run_command systemctl --user daemon-reload
run_command systemctl --user start tutorial.service
run_podman ps
clear

run_command systemctl --user stop tutorial.service

# Point to Ygal's article which goes into great detail.
run_command firefox --new-window https://www.redhat.com/sysadmin/multi-container-application-podman-quadlet
clear
