#!/usr/bin/env sh

source helpers.bash
setup
clear

# SECCOMP (Secure Computing) is a security mechanism of the Linux working on
# the granularity of system calls.  Among other things, it allows for
# selectively enabling and disabling certain system calls for processes.  This
# makes seccomp a widely used security mechanism in the containers space.
#
# Most container engines such as Podman and Docker use a default seccomp
# profile.  This profile's main purpose is to avoid obvious disasters such as a
# container rebooting the machine.  Since it's used by default, we had to make
# sure that almost all container workloads work by default: the good old
# optimization problem of usability and security.
#
# It's worth mentioning that the default profile enables around 300 syscalls
# from the 430+ available on X86_64.  An average container, however, only needs
# 40-70 syscalls.  So there is a huge potential of attack surface reduction of
# around 80 percent if we had custom tailored profiles.
#
# Writing custom seccomp profiles is very hard and requires a deep
# understanding of not only the container workload but also of the container
# engine and the kernel.  Hence, we semi-automated the generation of such
# seccomp profiles with the `oci-seccomp-bpf-hook`.
#
# Please refer to the following article for more details:
# https://www.redhat.com/sysadmin/container-security-seccomp

run_command_root dnf install -y oci-seccomp-bpf-hook
clear

run_command less security/data/seccomp.json
clear

tmp=$(mktemp --suffix=.seccomp.json)
rm ${tmp}

# Now run the hook via the annotation.
run_podman_root run --annotation io.containers.trace-syscall=of:${tmp} $SOURCE_IMAGE ls /usr
clear

# Explain the profile structure on a high level to give a better feeling for
# what seccomp (and the tracer) does.
run_command jq . $tmp
clear

# Now run again to show that it's working just as expected.
run_podman_root run --security-opt=seccomp=${tmp} $SOURCE_IMAGE ls /usr
clear

# And also that it won't work with `-l`.
run_podman_root run --security-opt=seccomp=${tmp} $SOURCE_IMAGE ls -l /usr
