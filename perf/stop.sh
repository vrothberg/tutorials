#!/usr/bin/env sh
source ./helpers.bash

setup
echo_bold "Stop $RUNS container in a row"
hyperfine --warmup 10 --runs $RUNS \
	--prepare "$PODMAN rm -f 123 || true; $PODMAN run -d --name=123 $IMAGE top" \
	--prepare "$DOCKER rm -f 123 || true; $DOCKER run -d --name=123 $IMAGE top" \
	"$PODMAN stop 123" \
	"$DOCKER stop 123"
