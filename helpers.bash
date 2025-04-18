bold=$(tput bold)
reset=$(tput sgr0)
color="$(tput setaf 2)"

# Pin it the image to a specific tag to make sure
# the scripts won't silently regress in the future.
SOURCE_IMAGE=registry.access.redhat.com/ubi9:9.0.0
IMAGE="${IMAGE:-tutorial}"
DINDIMAGE=nested-docker
MINIMAGE=fedora-minimal:37

PODMAN=${PODMAN:-podman}

function prompt() {
    read -p "${bold}${color}$1${reset}"
}

function echo_bold() {
    echo "${bold}${color}$1${reset}"
}

function run_command() {
	prompt "\$ $*"
	command $@
	read -p ""
}

function run_command_no_prompt() {
	echo_bold "\$ $*"
	$@
	echo ""
}

function run_command_root() {
	run_command sudo $@
}

function run_command_no_prompt_root() {
	run_command_no_prompt sudo $@
}

function run_podman() {
	run_command $PODMAN $@
}

function run_podman_root() {
	run_command sudo $PODMAN $@
}

function run_podman_no_prompt() {
	run_command_no_prompt $PODMAN $@
}

function run_podman_no_prompt_root() {
	run_command_no_prompt sudo $PODMAN $@
}

function build_image() {
	# The Red Hat/CentOS/Fedora images are quite trimmed down
	# so we need to install a number of packages.
	containerfile=$(mktemp)
	cat >$containerfile <<EOF
FROM $SOURCE_IMAGE
RUN dnf install -y procps-ng
# Create a 2nd layer to force an intermediate image
RUN dnf install -y diffutils
EOF
	run_command_no_prompt $PODMAN build -f $containerfile -t $IMAGE
	rm $containerfile
}

function build_image_root() {
	# The Red Hat/CentOS/Fedora images are quite trimmed down
	# so we need to install a number of packages.
	containerfile=$(mktemp)
	cat >$containerfile <<EOF
FROM $SOURCE_IMAGE
RUN dnf install -y procps-ng
# Create a 2nd layer to force an intermediate image
RUN dnf install -y diffutils
EOF
	run_command_no_prompt_root $PODMAN build -f $containerfile -t $IMAGE
	rm $containerfile
}

function require_tool() {
    	command -v $1 >/dev/null
    	if [ $? != 0 ]; then
		echo $0 requires the $1 package to be installed
		exit 1
    	fi
}

function cleanup() {
    	run_podman_no_prompt rm -af -t0
    	run_podman_no_prompt rmi -af
    	run_podman_no_prompt system prune -af
    	run_podman_no_prompt_root rm -af -t0
    	run_podman_no_prompt_root system prune -af
}

function setup() {
	require_tool podman
	require_tool skopeo
	require_tool docker
    	build_image
    	clear
}

function random_string() {
    local length=${1:-10}

    head /dev/urandom | tr -dc a-zA-Z0-9 | head -c$length
}
