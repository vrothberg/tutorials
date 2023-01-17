#!/usr/bin/env sh

source helpers.bash

run_podman_no_prompt rm -af
run_podman_no_prompt docker.io/mariadb docker.io/wordpress
clear

# This tutorial is meant to show how users can move their local containers and
# pods to a K8s YAML and thereby to Kubernetes and OpenShift.

run_podman pod create --name=tutorial-pod -p 8080:80
clear

run_podman run -d --pod=tutorial-pod \
  -e MYSQL_ROOT_PASSWORD="tutorial" \
  -e MYSQL_DATABASE="tutorial-db" \
  -e MYSQL_USER="tutorial-user" \
  -e MYSQL_PASSWORD="tutorial-pw" \
  --name=tutorial-db docker.io/mariadb
clear

run_podman run -d --pod=tutorial-pod \
  -e WORDPRESS_DB_NAME="tutorial-db" \
  -e WORDPRESS_DB_USER="tutorial-user" \
  -e WORDPRESS_DB_PASSWORD="tutorial-pw" \
  -e WORDPRESS_DB_HOST="127.0.0.1" \
  --name=tutorial-wp docker.io/wordpress
clear

run_podman pod ps
run_podman ps
clear

kubefile=$(mktemp --suffix ".yaml")
run_podman kube generate tutorial-pod > $kubefile
run_command less $kubefile
clear

run_podman rm -af -t0
clear

run_podman kube play $kubefile
clear

run_podman pod ps
run_podman ps
clear

run_command firefox --new-window http://localhost:8080
clear
