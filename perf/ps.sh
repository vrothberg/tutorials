#!/usr/bin/env sh
source ./helpers.bash

setup
echo_bold "List $NUM_CONTAINERS containers"
create_containers
hyperfine --warmup 10 --runs $RUNS \
	"$PODMAN ps -a" \
	"$DOCKER ps -a"
