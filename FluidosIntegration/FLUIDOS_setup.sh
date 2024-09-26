#!/bin/bash

# Set parameters
LOCAL_K8S_CLUSTER_CP_IP="192.168.11.91"
LOCAL_REAR_PORT="10000"
REMOTE_K8S_CLUSTER_CP_IP="192.168.11.94"
REMOTE_REAR_PORT="10000"

# Function to download the consumer-values.yaml file from the GitHub repository
download_consumer_values() {
  curl -o consumer-values.yaml https://raw.githubusercontent.com/fluidos-project/node/main/quickstart/utils/consumer-values.yaml
}

# Function to install the FLUIDOS Node component via helm
install_fluidos_node() {
  helm repo add fluidos https://fluidos-project.github.io/node/
  download_consumer_values
  helm install node fluidos/node -n fluidos \
    --create-namespace -f consumer-values.yaml \
    --set networkManager.configMaps.nodeIdentity.ip="$LOCAL_K8S_CLUSTER_CP_IP:$LOCAL_REAR_PORT" \
    --set networkManager.configMaps.providers.local="$REMOTE_K8S_CLUSTER_CP_IP:$REMOTE_REAR_PORT" \
    --wait
}

# Function to delete the FLUIDOS Node component via helm
delete_fluidos_node() {
  helm delete node -n fluidos
}

# Check for command-line argument
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 [apply|delete]"
  exit 1
fi



# Perform action based on the argument
case "$1" in
  apply)
    install_fluidos_node
    ;;
  delete)
    delete_fluidos_node
    ;;
  *)
    echo "Error: Invalid argument. Use 'apply' to install or 'delete' to remove the deployment."
    exit 1
    ;;
esac
