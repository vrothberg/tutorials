#!/usr/bin/env sh

bold=$(tput bold)      
reset=$(tput sgr0)     
color="$(tput setaf 2)"

if [ `id -u` -ne 0 ]; then
	echo "Please run as root"
	exit 1
fi

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

clear
prompt "Example scenario RHEL SST QEs will face going forward. Best practices to test on Image Mode?"
echo ""

prompt "Task: make sure the integration tests of github.com/vrothberg/vgrep pass in Image Mode."
echo ""

prompt "After a bit of fiddling, I ended up with the following Dockerfile:"


run_command nvim Dockerfile
clear

run_command podman build -t vgrep:bootc .
clear


prompt "The user stories explicitly mentioned a local dev-test cycle with Podman and the OCI container before transitioning to an Image Mode host. So let's run the tests in a local Podman container:"
echo""
run_command podman run --detach --name=vgrep --replace vgrep:bootc

echo""
prompt "Running the container in --detached mode allows for systemd to be PID1 and initialize the bootc container as intended. We can now exec' into the container to get some work done:"
echo ""
run_command podman exec -it vgrep bash
clear

prompt "The next steps in the developer workflow have already been demoed:"
echo ""
prompt " * Use bootc-image-builder to convert and boot the disk image."
echo ""
prompt " * Use podman-bootc to automate the conversion and booting."
clear

prompt "Lessons learned ..."
echo ""
prompt " 1) Bootc images are OCI images with specific attributes users need to be familiar with. They do behave differently!"
echo ""
prompt " 2) When working locally, make sure to start the bootc container with systemd and then podman-exec into it. This makes sure the systemd services have fired."
echo ""
prompt " 3) The docs contain all information but they are scattered.  We need on-boarding docs and provide best practices."
echo ""
prompt " 4) After RHEL 9.5 I want to pay more attention to the developer experience and enablement."
