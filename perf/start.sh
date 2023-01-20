#!/usr/bin/env sh
source ./helpers.bash

setup
echo_bold "Start $RUNS container in a row"
hyperfine --warmup 10 --runs $RUNS \
	--prepare "$PODMAN rm -f 123 || true; $PODMAN create --name=123 $IMAGE true" \
	--prepare "$DOCKER rm -f 123 || true; $DOCKER create --name=123 $IMAGE true" \
	"$PODMAN start 123" \
	"$DOCKER start 123"
