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
  exit 0
else
  ./FLUIDOS_setup.sh apply $1
  sleep 10 # wait for liqo to be found ready by the fluidos rear controller
  cd fluidos-chart
  ./deploy.sh $1
  exit 0
fi