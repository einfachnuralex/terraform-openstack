#!/bin/bash

echo "do ske stuff"

if ! type "helm"; then
  echo "helm is required, not in PATH"
  exit 1
fi

if ! type "kubectl" > /dev/null; then
  echo "kubectl is required, not in PATH"
  exit 1
fi

helm repo add stackit https://registry.alpha.ske.eu01.stackit.cloud/chartrepo/stackit
helm repo update
helm upgrade --install skeinit stackit/ske-init -n kube-system --set global.clustername=$CLUSTER_NAME
