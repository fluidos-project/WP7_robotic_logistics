#!/bin/bash

# Function to deploy the Helm chart with the specified role
deploy_chart() {
  local role=$1
  helm upgrade --install fluidos-integration . \
    --set nodes.role=$role
}

# Function to delete the Helm deployment
delete_chart() {
  helm delete fluidos-integration
}

# Check the value of the first argument
case "$1" in
  edge)
    deploy_chart "edge"
    ;;
  robot)
    deploy_chart "robot"
    ;;
  delete)
    delete_chart
    ;;
  *)
    echo "Usage: $0 {edge|robot|delete}"
    exit 1
    ;;
esac