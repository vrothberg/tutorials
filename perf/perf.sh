PODMAN=${PODMAN:-/usr/bin/podman}
DOCKER=${DOCKER:-/usr/bin/docker}
RUNS=${RUNS:-100}
NUM_CONTAINERS=${NUM_CONTAINERS:-100}

BOLD="$(tput bold)"
RESET="$(tput sgr0)"

IMAGE="docker.io/library/alpine:latest"

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

setup
echo_bold "Create $RUNS containers"
hyperfine --warmup 10 --runs $RUNS \
	"$PODMAN create $IMAGE" \
	"$DOCKER create $IMAGE"

setup
echo_bold "List $NUM_CONTAINERS containers"
create_containers
hyperfine --warmup 10 --runs $RUNS \
	"$PODMAN ps -a" \
	"$DOCKER ps -a"

setup
echo_bold "Remove $RUNS container in a row"
hyperfine --warmup 10 --runs $RUNS \
	--prepare "$PODMAN create --name=123 $IMAGE" \
	--prepare "$DOCKER create --name=123 $IMAGE" \
	"$PODMAN rm 123" \
	"$DOCKER rm 123"

setup
echo_bold "Start $RUNS container in a row"
hyperfine --warmup 10 --runs $RUNS \
	--prepare "$PODMAN rm -f 123 || true; $PODMAN create --name=123 $IMAGE true" \
	--prepare "$DOCKER rm -f 123 || true; $DOCKER create --name=123 $IMAGE true" \
	"$PODMAN start 123" \
	"$DOCKER start 123"

setup
echo_bold "Stop $RUNS container in a row"
hyperfine --warmup 10 --runs $RUNS \
	--prepare "$PODMAN rm -f 123 || true; $PODMAN run -d --name=123 $IMAGE top" \
	--prepare "$DOCKER rm -f 123 || true; $DOCKER run -d --name=123 $IMAGE top" \
	"$PODMAN stop 123" \
	"$DOCKER stop 123"
