#!/bin/bash

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
  liqoctl uninstall --verbose --purge --skip-confirm
  exit 0
else
  liqoctl install k3s --cluster-name $(hostname)
  sleep 10
  ./FLUIDOS_setup.sh apply $1
  sleep 30 # wait for liqo to be found ready by the fluidos rear controller
  cd fluidos-chart
  ./deploy.sh $1
  exit 0
fi