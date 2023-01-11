#!/usr/bin/env sh

source helpers.bash

# Must nuke everything to clean up all secrets
run_podman_no_prompt system reset -f
clear

secretfile=$(mktemp --suffix ".secret.yaml")
cat >$secretfile <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: tutorial-secret
type: Opaque
data:
  username: dXNlcg==
  password: NTRmNDFkMTJlOGZh
EOF

# Show a simple K8s-secret YAML
run_command cat $secretfile
clear

# This should indicate that a secret has been created but Podman v4.3.1 (and
# earlier and possibly some versions after) don´t. The following issue is
# tracking the bug: https://github.com/containers/podman/issues/17071
run_podman kube play $secretfile

#run_podman secret list
#clear
#
## Now inspect the secret and elaborate a bit on the output.
#run_podman secret inspect tutorial-secret
#clear
#
## Show that the "filedriver" is really just a file-based key-value store
## formatted as JSON.
#run_command cat $($PODMAN secret inspect tutorial-secret --format "{{.Spec.Driver.Options.path}}")/secretsdata.json
#clear

# Now run a pod using the secret.
kubefile=$(mktemp --suffix ".yaml")
cat >$kubefile <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: tutorial-pod
spec:
  containers:
    - name: container
      image: alpine
      command:
       - top
      volumeMounts:
        - name: secret-mount
          mountPath: /secret
          readOnly: true
  volumes:
    - name: secret-mount
      secret:
        secretName: tutorial-secret
EOF

run_command cat $kubefile
clear

run_podman kube play $kubefile
clear

run_podman pod ps
run_podman ps
clear

run_podman exec tutorial-pod-container cat /secret/username
run_podman exec tutorial-pod-container cat /secret/password
