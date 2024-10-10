#!/bin/bash



# Function to deploy the Helm chart with the specified role
deploy_chart() {
  local role=$1
  echo "Deploying Helm chart with role: $role"
  helm upgrade --install fluidos-integration . \
    --set nodes.role=$role --wait
}

# Function to delete the Helm deployment
delete_chart() {
  helm uninstall fluidos-integration
  # Wait for all resources to be deleted
  while kubectl get all -l release=fluidos-integration -n default | grep -q fluidos-integration; do
    echo "Waiting for resources to be deleted..."
    sleep 5
  done
  echo "All resources deleted."
}

# Function to generate the Helm chart template
template_chart() {
  helm template .
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
  template)
    template_chart
    ;;
  *)
    echo "Usage: $0 {edge|robot|delete|template}"
    exit 1
    ;;
esac