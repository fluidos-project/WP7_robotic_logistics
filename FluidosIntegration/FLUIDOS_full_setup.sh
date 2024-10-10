#!/bin/bash

# Exit on error
#set -e

# Function to check if liqoctl is up and running
check_liqoctl_status() {
  while kubectl get -n liqo deployments.apps | tail -n +2 | awk '{print $2, $3, $4}' | grep -q 0; do
    echo "Waiting for Liqo to be up and running..."
    sleep 5
  done
}



# Check for command-line argument
if [ -z "$1" ]; then
  echo "Error: Missing argument. Use 'edge' to install the Edge node, 'robot' to install the Robot node or delete to delete the Helm deployment."
  exit 1
fi

if [ "$1" != "edge" ] && [ "$1" != "robot" ] && [ "$1" != "delete" ]; then
  echo "Error: Invalid argument. Use 'edge' to install the Edge node, 'robot' to install the Robot node or delete to delete the Helm deployment."
  exit 1
fi


# Function to check if "Liqo is ready" appears in the logs of a deployment
check_logs() {
    local deployment=$1
    local selector=$2
    local pod_name
    # Get the pod name from the deployment using the provided selector
    pod_name=$(kubectl get pods -n $NAMESPACE -l $selector -o jsonpath="{.items[0].metadata.name}")
    # Wait until the message appears in the logs
    until kubectl logs $pod_name -n $NAMESPACE | grep -q "Liqo is ready"; do
        echo "Waiting for $deployment to be ready..."
        sleep 5
    done
    echo "$deployment is ready!"
}


if [ "$1" == "delete" ]; then
  # unoffload all offloaded namespaces
  offloaded_namespaces=$(kubectl get namespaceoffloadings.offloading.liqo.io -o=yaml | grep namespace: | awk '{print $2}')
  for namespace in "$offloaded_namespaces"; do
    echo "deleting offloaded namespace $namespace"
    liqoctl unoffload namespace $namespace --skip-confirm
  done
  
  # delete fluidos deployment (solver and discovery)
  cd fluidos-chart
  ./deploy.sh delete
  cd ..
  ./FLUIDOS_setup.sh delete
  
  # removing existing peers to allow for liqo to be uninstalled
  peers=$(kubectl get -n liqo foreignclusters.discovery.liqo.io | tail -n +2 | awk '{print $1}')
  echo "current peers: $peers"
  for peer in $peers; do
    echo "deleting peer $peer"
    liqoctl unpeer $peer --skip-confirm
  done
  
  liqoctl uninstall --verbose --purge --skip-confirm
  exit 0
else
  liqoctl install k3s --cluster-name $(hostname)

  check_liqoctl_status

  ./FLUIDOS_setup.sh apply $1
  # wait for the Liqo is ready log message from the node-rear-manager deployment
  # this is needed to ensure that the fluidos daemon is able to connect to the Liqo cluster
  
  # Define the deployments and their selectors
  #declare -A DEPLOYMENTS
  #DEPLOYMENTS=(
  #    ["node-rear-manager"]="app.kubernetes.io/component=rear-manager"
  #    ["local-resource-manager"]="app.kubernetes.io/component=resource-manager"
  #    ["node-rear-controller"]="app.kubernetes.io/component=rear-controller"
  #)

  #

  ## Loop through the deployments and check the logs for each one
  #for deployment in "${!DEPLOYMENTS[@]}"; do
  #    check_logs $deployment "${DEPLOYMENTS[$deployment]}"
  #done
  sleep 15 # need to wait for the fluidos daemon to say that liqo is ready
  cd fluidos-chart
  ./deploy.sh $1
  exit 0
fi