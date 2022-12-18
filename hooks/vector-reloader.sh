#!/usr/bin/env bash

source /shell_lib.sh

function __config__() {
  cat << EOF
    configVersion: v1
    schedule:
    - crontab: "0 * * * *"
      allowFailure: true
      group: "main"
      includeSnapshotsFrom: ["d8_vector_pods"]
    kubernetes:
    - name: d8_vector_pods
      apiVersion: v1
      kind: Pod
      group: "main"
      executeHookOnEvent: []
      namespace:
        nameSelector:
          matchNames:
          - d8-log-shipper
      jqFilter: ".metadata.name"
EOF
}

function __main__() {
  echo "Starting vector restart hook..."
  vectorPods=$(context::jq -r '.snapshots.d8_vector_pods[] | .filterResult' | tr '\n' ' ')
  echo "Fount pods: ${vectorPods}. Deleting..."
  kubectl -n d8-log-shipper delete pod ${vectorPods}
  exit 0
}

hook::run "$@"
