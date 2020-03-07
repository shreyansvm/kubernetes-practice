# Notes on DaemonSet
- Ensures all (or some subset) Nodes run a copy of the Pod.
- As nodes get added, pods also get added
- As nodes get removed, the pods will also get garbage collected

## Use cases:
For running
- Cluster-wide storage daemon (e.g. glusterfs, ceph)
- Log collection daemon (e.g. fluentd)
- Node monitoring daemon (e.g. Prometheus, Collectd)

## Alternatives to DaemonSet
- Initialization scripts
- Bare Pods: directly specifying which nodes the Pod will run on. But this is not recommended way.

### Sample creation:
This example was tried on a K8s cluster with 2 nodes. 

One of the nodes was tainted
```
shreyans_mulkutkar@cloudshell:~/my_utilities/daemonsets (smulkutk-project-1)$ kubectl get nodes
NAME                                         STATUS   ROLES    AGE     VERSION
gke-k8s-cluster-default-pool-384bf091-9zjr   Ready    <none>   5h23m   v1.14.10-gke.17
gke-k8s-cluster-default-pool-384bf091-jgv5   Ready    <none>   5h23m   v1.14.10-gke.17
shreyans_mulkutkar@cloudshell:~/my_utilities/daemonsets (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/daemonsets (smulkutk-project-1)$ kubectl taint node gke-k8s-cluster-default-pool-384bf091-9zjr env=dev:NoSchedule
node/gke-k8s-cluster-default-pool-384bf091-9zjr tainted
shreyans_mulkutkar@cloudshell:~/my_utilities/daemonsets (smulkutk-project-1)$
```

The 'example-fluentd-daemonset.yaml' file specifies that Pods should not be scheduled on node with 'env=dev:NoSchedule' taint.

Therefore the Pod gets scheduled only on one node.
```
shreyans_mulkutkar@cloudshell:~/my_utilities/daemonsets (smulkutk-project-1)$ kubectl apply -f example-fluentd-daemonset.yaml 
daemonset.extensions/example-fluentd-daemonset created
shreyans_mulkutkar@cloudshell:~/my_utilities/daemonsets (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/daemonsets (smulkutk-project-1)$ kubectl get all -o wide
NAME                                  READY   STATUS    RESTARTS   AGE   IP           NODE                                         NOMINATED NODE   READINESS GATES
pod/example-fluentd-daemonset-2gtlc   1/1     Running   0          39s   10.48.0.23   gke-k8s-cluster-default-pool-384bf091-jgv5   <none>           <none>

NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/kubernetes   ClusterIP   10.51.240.1   <none>        443/TCP   28m   <none>

NAME                                       DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE   CONTAINERS              IMAGES                                         SELECTOR
daemonset.apps/example-fluentd-daemonset   1         1         1       1            1           <none>          39s   fluentd-elasticsearch   quay.io/fluentd_elasticsearch/fluentd:v2.5.2   app=fluentd,type=daemonset-pods
shreyans_mulkutkar@cloudshell:~/my_utilities/daemonsets (smulkutk-project-1)$
```

DaemonSet details -
```
shreyans_mulkutkar@cloudshell:~/my_utilities/daemonsets (smulkutk-project-1)$ kubectl describe daemonsets example-fluentd-daemonset
Name:           example-fluentd-daemonset
Selector:       app=fluentd,type=daemonset-pods
Node-Selector:  <none>
Labels:         app=fluentd
Annotations:    deprecated.daemonset.template.generation: 1
                kubectl.kubernetes.io/last-applied-configuration:
                  {"apiVersion":"extensions/v1beta1","kind":"DaemonSet","metadata":{"annotations":{},"labels":{"app":"fluentd"},"name":"example-fluentd-daem...
Desired Number of Nodes Scheduled: 1
Current Number of Nodes Scheduled: 1
Number of Nodes Scheduled with Up-to-date Pods: 1
Number of Nodes Scheduled with Available Pods: 1
Number of Nodes Misscheduled: 0
Pods Status:  1 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=fluentd
           type=daemonset-pods
  Containers:
   fluentd-elasticsearch:
    Image:        quay.io/fluentd_elasticsearch/fluentd:v2.5.2
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age   From                  Message
  ----    ------            ----  ----                  -------
  Normal  SuccessfulCreate  72s   daemonset-controller  Created pod: example-fluentd-daemonset-2gtlc
shreyans_mulkutkar@cloudshell:~/my_utilities/daemonsets (smulkutk-project-1)$
```
