#!/bin/python3
import threading
import time
from kubernetes import client, config, watch
from termcolor import colored
import itertools

# Load Kubernetes configuration
config.load_kube_config()

# Define colors for deployments
colors = ['red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'white']
color_cycle = itertools.cycle(colors)

# Dictionary to store deployment colors
deployment_colors = {}

# Function to stream logs from a single pod
def stream_pod_logs(deployment_name, pod_name, namespace):
    v1 = client.CoreV1Api()
    w = watch.Watch()
    color = deployment_colors[deployment_name]
    try:
        print(colored(f"[{deployment_name}] Starting log stream for pod {pod_name}", color))
        for log in w.stream(v1.read_namespaced_pod_log, name=pod_name, namespace=namespace, follow=True):
            if "Refreshing cache" in log:
                continue
            print(f"[{colored(deployment_name, color)}] {log}")
    except Exception as e:
        print(f"[{colored(deployment_name, color)}] Error: {e}")
        exit(1)

# Function to monitor logs from all pods in a deployment
def monitor_deployment_logs(deployment_name, namespace):
    apps_v1 = client.AppsV1Api()
    v1 = client.CoreV1Api()
    while True:
        try:
            pods = v1.list_namespaced_pod(namespace)
            for pod in pods.items:
                if not deployment_name in pod.metadata.name:
                    continue
                threads = []
                for pod in pods.items:
                    print(colored(f"[{deployment_name}] Found pod {pod.metadata.name}", 'cyan'))
                    t = threading.Thread(target=stream_pod_logs, args=(deployment_name, pod.metadata.name, namespace))
                    t.start()
                    threads.append(t)
                for t in threads:
                    t.join()
        except Exception as e:
            print(colored(f"[{deployment_name}] Error: {e}", 'red'))
            exit(1)
        time.sleep(10)  # Check for new deployments and pods every 10 seconds

# Main function to start monitoring logs from multiple deployments
def main(deployments, namespace):
    threads = []
    for deployment in deployments:
        deployment_colors[deployment] = next(color_cycle)
        t = threading.Thread(target=monitor_deployment_logs, args=(deployment, namespace))
        t.start()
        threads.append(t)
    for t in threads:
        t.join()

if __name__ == "__main__":
    # List of deployments to monitor
    deployments = ["node-local-resource-manager", "node-rear-controller", "node-rear-manager"]
    namespace = "fluidos"
    main(deployments, namespace)