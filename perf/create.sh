#!/usr/bin/env sh
source ./helpers.bash

setup
echo_bold "Create $RUNS containers"
hyperfine --warmup 10 --runs $RUNS \
	"$PODMAN create $IMAGE" \
	"$DOCKER create $IMAGE"