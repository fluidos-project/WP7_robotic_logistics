#!/bin/bash

# Set parameters
LOCAL_K8S_CLUSTER_CP_IP="192.168.11.91"
LOCAL_REAR_PORT="30000"
REMOTE_K8S_CLUSTER_CP_IP="192.168.11.94"
REMOTE_REAR_PORT="30000"

# Function to download the consumer-values.yaml file from the GitHub repository
download_consumer_values() {
  curl -o consumer-values.yaml https://raw.githubusercontent.com/fluidos-project/node/main/quickstart/utils/consumer-values.yaml
}

#!/bin/bash

# Variables
NODE_NAME=$(hostname)
LABEL_KEY1="node-role.fluidos.eu/worker"
LABEL_VALUE1="true"
LABEL_KEY2="node-role.fluidos.eu/resources"
LABEL_VALUE2="true"


declare -A LABELS
LABELS["node-role.fluidos.eu/worker"]="true"
LABELS["node-role.fluidos.eu/resources"]="true"

# Loop over the labels and check/add them
for LABEL_KEY in "${!LABELS[@]}"; do
  LABEL_VALUE=${LABELS[$LABEL_KEY]}
  LABEL_EXISTS=$(kubectl get node $NODE_NAME --show-labels | grep "$LABEL_KEY=$LABEL_VALUE")

  if [ -z "$LABEL_EXISTS" ]; then
    kubectl label node $NODE_NAME $LABEL_KEY=$LABEL_VALUE
    echo "Label $LABEL_KEY=$LABEL_VALUE added to node $NODE_NAME"
  else
    echo "Node $NODE_NAME already has the label $LABEL_KEY=$LABEL_VALUE"
  fi
done


# Function to install the FLUIDOS Node component via helm
install_fluidos_node() {

  helm repo add fluidos https://fluidos-project.github.io/node/
  download_consumer_values

  if [ $1 == "robot" ]; then
    helm upgrade --install node fluidos/node -n fluidos \
      --create-namespace -f consumer-values.yaml \
      --set networkManager.configMaps.nodeIdentity.ip="$LOCAL_K8S_CLUSTER_CP_IP:$LOCAL_REAR_PORT" \
      --set networkManager.configMaps.providers.local="$REMOTE_K8S_CLUSTER_CP_IP:$REMOTE_REAR_PORT" \
      --wait --debug --v=2
  elif [ $1 == "edge" ]; then
    helm upgrade --install node fluidos/node -n fluidos \
      --create-namespace -f consumer-values.yaml \
      --set networkManager.configMaps.nodeIdentity.ip="$REMOTE_K8S_CLUSTER_CP_IP:$REMOTE_REAR_PORT" \
      --set networkManager.configMaps.providers.local="$LOCAL_K8S_CLUSTER_CP_IP:$LOCAL_REAR_PORT" \
      --wait --debug --v=2
  else
    echo "Error: Invalid argument. Use 'edge' to install the Edge node or 'robot' to install the Robot node."
    exit 1
  fi
}

# Function to delete the FLUIDOS Node component via helm
delete_fluidos_node() {
  helm delete node -n fluidos --debug --v=2
}

# Check for command-line argument
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ] ; then
  echo "Usage: $0 [apply|delete]"
  exit 1
fi



# Perform action based on the argument
case "$1" in
  apply)
    install_fluidos_node $2
    ;;
  delete)
    delete_fluidos_node
    ;;
  *)
    echo "Error: Invalid argument. Use 'apply' to install or 'delete' to remove the deployment."
    exit 1
    ;;
esac
