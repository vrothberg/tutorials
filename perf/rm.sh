#!/usr/bin/env sh
source ./helpers.bash

setup
echo_bold "Remove $RUNS container in a row"
hyperfine --warmup 10 --runs $RUNS \
	--prepare "$PODMAN create --name=123 $IMAGE" \
	--prepare "$DOCKER create --name=123 $IMAGE" \
	"$PODMAN rm 123" \
	"$DOCKER rm 123"
