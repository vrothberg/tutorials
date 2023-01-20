PODMAN=${PODMAN:-/usr/bin/podman}
DOCKER=${DOCKER:-/usr/bin/docker}
RUNS=${RUNS:-100}
NUM_CONTAINERS=${NUM_CONTAINERS:-100}
IMAGE=${IMAGE:-docker.io/library/alpine:latest}

BOLD="$(tput bold)"
RESET="$(tput sgr0)"

function echo_bold() {
    echo "${BOLD}$1${RESET}"
}

function pull_image() {
	$PODMAN pull $IMAGE -q > /dev/null
	$DOCKER pull $IMAGE -q > /dev/null
}

function setup() {
        echo_bold "---------------------------------------------------"
	$PODMAN system prune -f > /dev/null
	$DOCKER system prune -f > /dev/null
	pull_image
}

function create_containers() {
	echo_bold "... creating $NUM_CONTAINERS containers"
	for i in $(eval echo "{0..$NUM_CONTAINERS}"); do
		$PODMAN create $IMAGE >> /dev/null
		$DOCKER create $IMAGE >> /dev/null
	done
}
