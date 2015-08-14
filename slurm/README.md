# Cloudmesh Virtual Cluster for Vagrant

This cluster is secified in an inventory.yml file:

```
    master:
     - name: master
       hostname: "master"
       ipaddress: "10.10.10.3"
   worker:
     - name: worker001
       hostname: "worker001"
       ipaddress: "10.10.10.4"
     - name: worker002
       hostname: "worker002"
       ipaddress: "10.10.10.5"
```

(In a future versiuon an in ventory can be automatically created with

```
cm-cluster create -n 2
```

which would create two worker nodes.)



Now you want to start some virtual machines while using the inventtory

```
cm-cluster create
```

To check the status we can use

```
cm-cluster status cm-cluster ping
```

To execute a command on all hosts we can say (lets use hostname)

```
cm-cluster shell hostanme
```

To submit a job test.sh that is specified in the current working dir
we can say

```
cm-cluster sbatch test.sh
```

We have not made it more conveinent to tech the result, so you can use

```
cm-cluster shell ls
```

to locate the slurm.out file (specified in test.sh) and than do

```
cm-cluster sell "cat slurm.out" WORKER
```

where WORKER is the hostname that contains the out file. We will provide in future more elaborate examples.

To destroy the cluster you can say

```
cm-cluster destroy
```

Note that will delete all virtual machines and files you may have
produced in them.
