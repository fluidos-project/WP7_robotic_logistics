# Robotic logistics

Kubernetes manifest files for simulation of a Robotnik RB-theron on ROS2

## Requirements

- Kubernetes >=1.25
- Ingress controller
- kubectl
- Helm

## Deployment

### Helm chart

[Helm chart documentation](charts/rb-theron-sim/README.md)

### helm repo

```bash
helm repo add fluidos-robotic-uc https://fluidos-project.github.io/robotic-logistics-use-case
helm repo update
helm upgrade --install test fluidos-robotic-uc/rb-theron-sim
```

### local development

```bash
git clone https://github.com/fluidos-project/robotic-logistics-use-case.git
cd robotic-logistics-use-case/helm
helm upgrade --install test ./rb-theron-sim  -f rb-theron-sim/values-iron-zenoh.yaml
```

### classic

```bash
git clone https://github.com/fluidos-project/robotic-logistics-use-case.git
cd robotic-logistics-use-case/k8s
kubectl create namespace robots
kubectl apply -f pseudo-chart
```

### nginx ingress controller install
```bash
cd helm-ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm upgrade \
 --install ingress-nginx ingress-nginx \
 --repo https://kubernetes.github.io/ingress-nginx \
 --namespace ingress-nginx \
 --create-namespace \
 -f values.yaml
```


## Alternative Deployment
```
You can use the `offload-switch-deploy.sh` script to automate the deployment of the `charts/rb-theron-sim-zenoh-bridge-dds`.
Using such script allows for the offloading demo to be easily performed.
For more information on how it works, look at the script.
```

## Usage

You can command the robot through rviz accessing the ingress Loadbalancer ip or url:

![k8s-ros2-rb-theron-rviz-web](doc/k8s-ros2-rb-theron-rviz-web.gif)

Step 1![rb-theron-rviz-01.png](doc/rb-theron-rviz-01.png)

Step 2![rb-theron-rviz-02.png](doc/rb-theron-rviz-02.png)

Step 3![rb-theron-rviz-03.png](doc/rb-theron-rviz-03.png)

Step 4![rb-theron-rviz-04.png](doc/rb-theron-rviz-04.png)

you also can access the gazebo interface using the ingress loadbalancer ip with path `gazebo`

Step 1![gazebo-01.png](doc/gazebo-01.png)

Step 2![gazebo-02.png](doc/gazebo-02.png)