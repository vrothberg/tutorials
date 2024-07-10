FROM quay.io/fedora/fedora-bootc:40

# Install the build, test and runtime dependencies
RUN dnf -y install git make golang bats ripgrep && dnf clean all

# Clone the git-tree to /var/grep: /var is writable
RUN git clone https://github.com/vrothberg/vgrep.git /var/vgrep

# /etc/alternatives doesn't work in fedora-bootc, see
# https://gitlab.com/fedora/bootc/tracker/-/issues/7.
#
# The following instruction works in the OCI container but is not visible on
# the bootc host: ENV PATH="$PATH:/usr/lib/golang/bin/"
#
# See https://containers.github.io/bootc/building/bootc-runtime.html#env-oci-env
#
# Best practice: symlink directly
RUN ln -sfr /usr/lib/golang/bin/go /usr/bin/go

# OCI images don't ship with the root's $HOME directory present as it's being
# created by a systemd unit on boot/init.
# 
# Best practice: podman run  -d $container
#                podman run -it $container bash
#
# Alternative: RUN mkdir -p /var/roothome
#              RUN cd /var/vgrep && make build


# NOTE: I intentionally ignore the existence of multi-stage builds.
#       It's an on-boarding scenario.
