# Objectives

# to retrieve the schema for the solver
kubectl get crd solvers.nodecore.fluidos.eu -o yaml

# downgraded to 0.0.6
I had to go back to version 0.0.6 of rear because 0.1.0 gives me problems with the yaml.

# BUGS
1. wrong solver example here: 
    - https://github.com/fluidos-project/node/blob/main/deployments/node/samples/solver-custom.yaml
    - this solver does not coincide with any of the schemas I got for both 0.1.0 and 0.0.6 with this command: `kubectl get crd solvers.nodecore.fluidos.eu -o yaml`
2. version 0.1.0 fails to validate this perfectly valid solver:
```
kind: Solver
metadata:
  name: solver-sample2
  namespace: fluidos
spec:
  selector:
    rangeSelector:
      minMemory: "6Gi"
      minCpu: "5000m"
      minStorage: "10Gi"
    type: k8s-fluidos
    architecture: amd64
  intentID: "intent-sample"
  findCandidate: true
  reserveAndBuy: true
  enstablishPeering: true
```
telling me that the spec.selector.architecture and the spec.selector.type are required fields, but clearly they are present.


## Behaviour to achieve
I have a robot as a fluidos node:
- by default the helm chart should deploy only locally
- when the robot is charging, all loads on it are freed to be used with fluidos for others (edgification)
- when the robot is detatched from the charge, it gets back all its pods except for navigation (offload)
- when the robot is in operation
- when a peering candidate is found that the solver has deemed as good and the robot is in operation, it should be automatically reserved, purchased and peered.
    - the solver should have:
        - specify the minimum resources to run the navigation in ram and cpu
        - K8sSlice
        - 
- the navigation is moved there (initially by daemon like a bash script on the robot, later by an orchestrator)
- when a peering candidate is found when the rob

## Steps needed
I want to specify its solver so that it takes all edge nodes available for offloading that have latency lower than a threshold and that have a the label "charging"
	- initially I just want it to take any other peering candidate available



## Questions:
- the liqo affinity  trick that I used before, does it work in fluidos too? (probably not, in fluidos there should be an orchestrator)
- what about the fluidos node orchestrator? does it exist at least in part? I would like to move the workload according to a logic if I can
- do I need to do anything on the edge? like advertising a subset of the node?
- il podfilter mi sembra abbastanza stupido/inutile come filtro
- quando il solver è creato trova il peering candidate ma può anche fare la allocation e reservation, quando è rimosso le rimuove automaticamente?

## Ideas
1. solver lato consumer needed
2. instead of flavour initially you can use an annotation on the node
3. reservation, purchase and allocation (should happen automatically)




