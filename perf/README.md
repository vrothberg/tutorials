# A set of scripts to compare the performance of two container engines

Run the scripts via `sudo sh $script.sh`.

Use the following environment variables to change the default behavior:
* `ENGINE_A` to set container engine A (default `/usr/bin/podman`)
* `ENGINE_B` to set container engine B (default `/usr/bin/docker`)
* `RUNS` to change the runs/repetitions of each benchmarks (default `100`)
* `NUM_CONTAINERS` to change the number of created containers for some benchmarks (e.g., `ps) (default `100`)
* `IMAGE` to change the default container image (default `docker.io/library/alpine:latest`)
