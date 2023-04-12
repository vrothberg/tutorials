#!/usr/bin/env sh

source helpers.bash
clear

# Let's jump directly into the subject by opening the `capabilities` man page.
# Things worth mentioning (in addition to going over the man page):
#
#  * Permission based security mechanism
#  * Can be compared to permission on our smartphones (e.g., camera access)
#  * Prior to Linux 2.2 (1999) we had two permissions: (non) privileged
#  * Soon it became clear that the world isn't always binary
#  * Since then, more and more capabilities have been added to the kernel (see man page)

run_command man capabilities
clear

dockerfile=$(mktemp --suffix ".Dockerfile")
cat >$dockerfile <<EOF
FROM $MINIMAGE
RUN  mknod /dev/mynull c 1 3
EOF

# Now let's give a more practical example of how we can debug a permission
# error.  In some cases, capabilities are missing.  The build below will fail
# because SYS_MKNOD is not part of the default capabilities.
run_command cat $dockerfile

run_podman_root build --no-cache -f $dockerfile
clear

# Let's check whether the EPERM is caused by a missing capability.
# A quick-and-easy way is using `--cap-add=all`.
run_podman_root build --no-cache -f $dockerfile --cap-add=all
clear

# Quite often capabilities are reasonably named, and since the `mknod` call
# fails, let's search for that in the man page.
run_command man capabilities
clear

# Et voila: the solution.
run_podman_root build --no-cache -f $dockerfile --cap-add=MKNOD
clear

# Last, open the `containers.conf` man page and point the user to the default
# capabilities and where these can be customised if needed.
run_command man containers.conf
