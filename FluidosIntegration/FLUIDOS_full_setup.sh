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

if [ "$1" == "delete" ]; then

  
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
  sleep 15
  cd fluidos-chart
  ./deploy.sh $1
  exit 0
fi