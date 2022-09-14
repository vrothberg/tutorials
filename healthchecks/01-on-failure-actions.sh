#!/usr/bin/env sh

source helpers.bash

setup

# Create a global temp directory to 1) build health-check images
#                                   2) be able to access its contents for demo purposes
TEMPDIR=$(mktemp -d)

# Modified version of containers/podman/test/system/helpers.bash
function _build_health_check_image {
    local imagename="$1"
    local cleanfile=""

    if [[ ! -z "$2" ]]; then
        cleanfile="rm -f /uh-oh"
    fi
    # Create an image with a healthcheck script; said script will
    # pass until the file /uh-oh gets created (by us, via exec)
    cat >${TEMPDIR}/healthcheck <<EOF
#!/bin/sh

if test -e /uh-oh; then
    echo "Uh-oh on stdout!"
    echo "Uh-oh on stderr!" >&2
    ${cleanfile}
    exit 1
else
    echo "Life is Good on stdout"
    echo "Life is Good on stderr" >&2
    exit 0
fi
EOF

    cat >${TEMPDIR}/entrypoint <<EOF
#!/bin/sh

trap 'echo Received SIGTERM, finishing; exit' SIGTERM; echo WAITING; while :; do sleep 0.1; done
EOF

    cat >${TEMPDIR}/Containerfile <<EOF
FROM $IMAGE

COPY healthcheck /healthcheck
COPY entrypoint  /entrypoint

RUN  chmod 755 /healthcheck /entrypoint

CMD ["/entrypoint"]
EOF

    $PODMAN build -t $imagename ${TEMPDIR}
}

imgname=healthcheck_image
ctrname=healthcheck_container

# Let's first build the image
_build_health_check_image $imgname 
clear

for policy in none stop kill restart; do
	prompt "Now running with on-failure action \"$policy\""
	echo_bold "--------------------------------------------"
	if [[ $policy == "restart" ]];then
		clear
		_build_health_check_image $imgname clean
		clear
	fi

	run_command cat ${TEMPDIR}/healthcheck
	clear
	
	run_command $PODMAN run --replace -d --name $ctrname --health-cmd /healthcheck --health-on-failure=$policy $imgname

	run_command $PODMAN healthcheck run $ctrname

	run_command $PODMAN ps

	run_command $PODMAN exec $ctrname touch /uh-oh

	run_command $PODMAN healthcheck run $ctrname
	run_command $PODMAN healthcheck run $ctrname

	run_command $PODMAN ps -a
	$PODMAN rm -f -t0 $ctrname > /dev/null
done

rm -rf $TEMPDIR
