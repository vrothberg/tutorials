#!/usr/bin/env sh

source helpers.bash

setup

# Need the busybox image for root{ful,less}
run_podman_no_prompt pull busybox
run_podman_no_prompt_root pull busybox

# Pull the docker image with docker for the docker-in-docker lesson
run_command_no_prompt_root docker pull docker
clear

# Outline:
#
# - Podman can run containers as root or as an ordinary rootless user on the system. Running as a rootless user makes containers portable as having root privileges is uncommon in many use cases and environments. Rootless containers also improve security which we shall explore in this chapter.
#
# - Privileged operations should only be required for modifying the core system. Running an ordinary process (i.e., a container) should not require such privileges. Historically though, root privileges were needed to make use of layered file systems (e.g., overlay FS) and certain network operations.  Today, these obstacles have been overcome by joint work of the kernel and containers community, with the Podman team being a main driving force.

name="tutorial"

# Show that rootless containers run with UID `id -u`
run_podman run --replace --rm --name=$name -d busybox sleep infinity
run_podman top $name huser,user
run_podman kill $name
clear

# Show that rootful containers run with UID 0
run_podman_root run --replace --rm --name=$name -d busybox sleep infinity
run_podman_root top $name huser,user
run_podman_root kill $name
clear

# - The obvious security benefit of using rootless containers is that, in the rare case of an exploit, an attacker cannot gain root access if they manage to break out of a container.  When running a rootful container, the attacker gains root privileges and hence the "holy grail".  It is worth highlighting that Docker usually runs as root despite newer versions of Docker supporting to run the daemon as non-root.  In many cases, users have the illusion of running Docker as a rootless user because they are part of the "docker" group granting them access to the Docker socket and by-proxy making them root on the host.

# Show that the socket is owned by root and gives access to the `docker` group.
# Explain why that's giving a dangerous illusion to users.
run_command stat /var/run/docker.sock
clear

# - A common use case is using "nested containers" (i.e., running a container inside another container).  You can find such deployments in CI/CD systems, for instance.  The architecture of the container engine plays a major role in such a deployment when it comes to security.  "Docker in Docker" is commonly implemented by mounting the Docker socket into the container, effectively giving (root) privileges on the host to the "nested" containers.  Running Podman inside a container does not suffer from this problem as Podman implements a fork-exec model.  We maintain images on quay.io/containers/podman for that purpose; the images can easily be deployed in many environments.  Please refer to the following article for details: https://www.redhat.com/sysadmin/podman-inside-container

# Show how running docker-in-docker with a mounted socket gives root access to the host.
run_command_root docker run --privileged -ti --rm -v /var/run/docker.sock:/var/run/docker.sock docker /bin/ash
clear

# Now run podman-in-podman and highlight the separation.
run_podman run --privileged -ti --rm podman sh
clear

# - A less obvious security implication of using a daemon as root is auditing.  Each process has a so-called login UID located in /proc/$PID/loginuid.  This ID gets assigned on login and will stick to any process that this user/process creates even when running `sudo $something`.  For Podman, the login UID will stick, even when running a rootful container.  For Docker, the login UID will be `4294967295`.  That is the overflow UID that does not allow for tracking back which user triggered a certain action.  The overflow UID is assigned since Docker is started by systemd which does not belong to a specific user.  Hence, Docker could not be used in security sensitive environments that require strict auditing capabilities on the system.

# Show the "stickiness" of the login UID.
run_command cat /proc/self/loginuid
run_command_root cat /proc/self/loginuid
clear

# Elaborate how the login UID ties into rootless (notice the user NS!) and rootful containers.
run_podman run -d --replace --name=$name busybox sleep infinity
run_podman exec $name cat /proc/self/loginuid
run_podman top $name huser,user
run_podman_root run --rm busybox cat /proc/self/loginuid

# Now show that Docker has the overflow login UID as it's started by systemd.
run_command_root docker run --rm docker cat /proc/self/loginuid
