#!/usr/bin/env sh

source helpers.bash
clear

# Make sure the hook is installed.
run_command_root dnf install -y oci-seccomp-bpf-hook
clear

tmp=$(mktemp --suffix=.seccomp.json)
rm ${tmp}

# Now run the hook via the annotation.
run_podman_root run --annotation io.containers.trace-syscall=of:${tmp} fedora:37 ls /
clear

# Explain the profile structure on a high level to give a better feeling for
# what seccomp (and the tracer) does.
run_command jq . $tmp
clear

# Now run again to show that it's working just as expected.
run_podman_root run --security-opt=seccomp=${tmp} fedora:37 ls / > /dev/null
clear

# And also that it won't work with `-l`.
run_podman_root run --security-opt=seccomp=${tmp} fedora:37 ls -l / > /dev/null
