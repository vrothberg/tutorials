bold=$(tput bold)
reset=$(tput sgr0)
color="$(tput setaf 2)"

# Pin it the image to a specific tag to make sure
# the scripts won't silently regress in the future.
SOURCE_IMAGE=registry.access.redhat.com/ubi9:9.0.0
IMAGE=container/tutorial

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

function build_image() {
	# The Red Hat/CentOS/Fedora images are quite trimmed down
	# so we need to install a number of packages.
	containerfile=$(mktemp)
	cat >$containerfile <<EOF
FROM $SOURCE_IMAGE
RUN dnf install -y procps-ng
EOF
	run_command_no_prompt podman build -f $containerfile -t $IMAGE
	rm $containerfile
}

function require_tool() {
    	command -v $1 >/dev/null
    	if [ $? != 0 ]; then
		echo $0 requires the $1 package to be installed
		exit 1
    	fi
}

function setup() {
	require_tool podman
	require_tool skopeo
    	build_image
    	podman rm -af -t0
    	clear
}

function random_string() {
    local length=${1:-10}

    head /dev/urandom | tr -dc a-zA-Z0-9 | head -c$length
}