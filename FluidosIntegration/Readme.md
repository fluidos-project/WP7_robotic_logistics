# Objectives

# to retrieve the schema for the solver
kubectl get crd solvers.nodecore.fluidos.eu -o yaml



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
- come facciamo a spostare un pod usando fluidos ed evitando la replica a zero?

  - what about the fluidos meta orchestrator? does it exist at least in part? I would like to move the workload according to a logic if I can

- dobbiamo creare un flavour o cosi va gia bene.

- il podfilter mi sembra abbastanza stupido/inutile come filtro
- come fa fluidos a rimuovere il peering?
- what does it mean for a flavour to be available? it seems that when I create a flavour this is automatically unavailable

- vedo un intentID ma non vedo un intent CRD da nessuna parte, cosa si intende per intent?
- come fa fluidos ad offloadare un namespace?
- FLUIDOS si occupa solo di fare peering? come vengono eliminati i peering? se elimino il solver il peering rimane! se tipo cambio il valore del solver automaticamente il peering viene eliminato?





