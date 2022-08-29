bold=$(tput bold)
cyan=$(tput setaf 6)
reset=$(tput sgr0)

SOURCE_IMAGE=registry.access.redhat.com/ubi9:latest
IMAGE=container/tutorial

function prompt() {
    read -p "${bold}$1${reset}"
}

function echo_color() {
    echo "${cyan}$1${reset}"
}

function echo_bold() {
    echo "${bold}$1${reset}"
}

function run_command() {
	prompt "\$ $*"
	$@
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

function setup() {
    	command -v podman >/dev/null
    	if [ $? != 0 ]; then
		echo $0 requires the podman package to be installed
		exit 1
    	fi
    	build_image
    	podman rm -af -t0
    	clear
}

function random_string() {
    local length=${1:-10}

    head /dev/urandom | tr -dc a-zA-Z0-9 | head -c$length
}
