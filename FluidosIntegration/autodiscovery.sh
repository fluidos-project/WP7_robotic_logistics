#!/bin/bash

# Set your variables
NAMESPACE="fluidos"
CONFIGMAP_NAME="fluidos-network-manager-config"
REMOTE_CLUSTER_NAME="edge"
REMOTE_CLUSTER_IP="192.168.11.94"
REMOTE_CLUSTER_PORT="30000"

# Set the number of ping attempts (optional)
PING_ATTEMPTS=3

RETRY_INTERVAL=10 # seconds

# Function to check if the remote cluster is reachable using ping
is_cluster_online() {
    # Ping the remote cluster and check if the ping is successful
    ping -c $PING_ATTEMPTS $REMOTE_CLUSTER_IP &> /dev/null
    if [ $? -eq 0 ]; then
        return 0  # Cluster is online (ping successful)
    else
        return 1  # Cluster is offline (ping failed)
    fi
}

# Function to add the new cluster information to the ConfigMap
patch_configmap_add() {
    # Add the new cluster information to the ConfigMap
    kubectl patch configmap $CONFIGMAP_NAME \
      -n $NAMESPACE \
      --patch "{\"data\": {\"$REMOTE_CLUSTER_NAME\": \"$REMOTE_CLUSTER_IP:$REMOTE_CLUSTER_PORT\"}}"
    echo "Patched ConfigMap $CONFIGMAP_NAME to add the $REMOTE_CLUSTER_NAME information: \"$REMOTE_CLUSTER_IP:$REMOTE_CLUSTER_PORT\""
}

# Function to remove the cluster information from the ConfigMap
patch_configmap_remove() {
    # Remove the cluster information from the ConfigMap
    kubectl patch configmap $CONFIGMAP_NAME \
      -n $NAMESPACE \
      --type=json \
      --patch "[{\"op\": \"remove\", \"path\": \"/data/$REMOTE_CLUSTER_NAME\"}]"
    echo "Patched ConfigMap $CONFIGMAP_NAME to remove the $REMOTE_CLUSTER_NAME information."
}

# Function to show a spinner animation while checking for the cluster status
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    printf "Pinging \"$REMOTE_CLUSTER_NAME\" "
    while kill -0 $pid 2>/dev/null; do
        for i in {1..4}; do
            printf "%s\b" "${spinstr:i%${#spinstr}:1}"
            sleep $delay
        done
    done
    printf " ✓\n"
}

# Main script loop to check for cluster status with spinner
while true; do
    is_cluster_online &
    pid=$!
    spinner $pid

    wait $pid
    if [ $? -eq 0 ]; then
        echo "\"$REMOTE_CLUSTER_NAME\" is online!"
        patch_configmap_add
        break
    else
        echo "\"$REMOTE_CLUSTER_NAME\" is offline!"
        #patch_configmap_remove
    fi

    echo "Retrying in 10 seconds..."
    sleep $RETRY_INTERVAL
done