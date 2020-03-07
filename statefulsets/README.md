# Notes on StatefulSets
- A StatefulSet is another Kubernetes controller that manages pods just like Deployments. But it differs from a Deployment in that it is more suited for stateful apps.
- How is it different from Deployment/Replicas?
  1. Deployements/Replicas are used for stateless applications.
  2. In case of stateless apps, like an Nginx web server, the client does not (and should not) care which pod receives a response to the request. The connection reaches the Service, and it routes it to any backend pod. 
  3. This is not the case in stateful apps. There might a tight coupling between the Pods and other objects (e.g. Nodes)
  4. For this reason, part of the Statefulset definition entails a Headless Service. A Headless Service does not contain a ClusterIP. Instead, it creates several Endpoints that are used to produce DNS records. Each DNS record is bound to a pod.
- all Pods are created from same spec
- Helps in managing Pods with sticky identity. i.e. each Pod will get persistent identity across rescheduling

## Use Cases:
- Ordered, graceful deployment and scaling
  - i.e. Pods are created/deployed in sequential order i.e. 0 to N-1
- Ordered, graceful deletion and termination
  - i.e. Pods are terminated in sequential order i.e. N-1 to 0
- Ordered, automated roling updates
- Stable, unique network identifiers
- Stable, persistent storage i.e. lifetime longer than the Pod.
  - Note: Pod must be provisioned using a PersistentVolume
  - Deleting or Scaling of StatefulSet will not trigger deletion/updation of associated volumes. 

### Creating a StatefulSet example -
Note: 
- Pods are labeled from 0 to configured 'replicas' (in this case=3)
```
shreyans_mulkutkar@cloudshell:~/my_utilities/statefulsets (smulkutk-project-1)$ kubectl apply -f example-nginx-statefulset.yaml --dry-run
service/statefulset-nginx created (dry run)
statefulset.apps/example-nginx-statefulset created (dry run)
shreyans_mulkutkar@cloudshell:~/my_utilities/statefulsets (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/statefulsets (smulkutk-project-1)$ kubectl apply -f example-nginx-statefulset.yaml
service/statefulset-nginx created
statefulset.apps/example-nginx-statefulset created
shreyans_mulkutkar@cloudshell:~/my_utilities/statefulsets (smulkutk-project-1)$

statefulset.apps/example-nginx-statefulset   2/3     4s
shreyans_mulkutkar@cloudshell:~/my_utilities/statefulsets (smulkutk-project-1)$ kubectl get all
NAME                              READY   STATUS    RESTARTS   AGE
pod/example-nginx-statefulset-0   1/1     Running   0          29s
pod/example-nginx-statefulset-1   1/1     Running   0          27s
pod/example-nginx-statefulset-2   1/1     Running   0          25s

NAME                        TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/kubernetes          ClusterIP   10.51.240.1   <none>        443/TCP   4h35m
service/statefulset-nginx   ClusterIP   None          <none>        80/TCP    29s

NAME                                         READY   AGE
statefulset.apps/example-nginx-statefulset   3/3     29s
shreyans_mulkutkar@cloudshell:~/my_utilities/statefulsets (smulkutk-project-1)$
```

### Scale-out a StatefulSet
A new Pod gets added with suffix '3' 
```
shreyans_mulkutkar@cloudshell:~/my_utilities/statefulsets (smulkutk-project-1)$ kubectl scale statefulset example-nginx-statefulset --replicas=4
statefulset.apps/example-nginx-statefulset scaled
shreyans_mulkutkar@cloudshell:~/my_utilities/statefulsets (smulkutk-project-1)$ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
example-nginx-statefulset-0   1/1     Running   0          66s
example-nginx-statefulset-1   1/1     Running   0          64s
example-nginx-statefulset-2   1/1     Running   0          62s
example-nginx-statefulset-3   1/1     Running   0          8s
shreyans_mulkutkar@cloudshell:~/my_utilities/statefulsets (smulkutk-project-1)$
```

### Scale-in a StatefulSet
The Pods will get deleted from N-1 onwards.
```
shreyans_mulkutkar@cloudshell:~/my_utilities/statefulsets (smulkutk-project-1)$ kubectl scale statefulset example-nginx-statefulset --replicas=2
statefulset.apps/example-nginx-statefulset scaled
shreyans_mulkutkar@cloudshell:~/my_utilities/statefulsets (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/statefulsets (smulkutk-project-1)$ kubectl get pods
NAME                          READY   STATUS        RESTARTS   AGE
example-nginx-statefulset-0   1/1     Running       0          3m15s
example-nginx-statefulset-1   1/1     Running       0          3m13s
example-nginx-statefulset-2   1/1     Running       0          3m11s
example-nginx-statefulset-3   0/1     Terminating   0          2m17s
shreyans_mulkutkar@cloudshell:~/my_utilities/statefulsets (smulkutk-project-1)$ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
example-nginx-statefulset-0   1/1     Running   0          3m22s
example-nginx-statefulset-1   1/1     Running   0          3m20s
shreyans_mulkutkar@cloudshell:~/my_utilities/statefulsets (smulkutk-project-1)$
```

Note:
- like deployments, StatefulSets do not have revisions. 

Example of 'describe statefulset'
```
shreyans_mulkutkar@cloudshell:~/my_utilities/statefulsets (smulkutk-project-1)$ kubectl describe sts
Name:               example-nginx-statefulset
Namespace:          default
CreationTimestamp:  Sat, 07 Mar 2020 12:11:23 -0800
Selector:           app=statefulset-nginx
Labels:             <none>
Annotations:        kubectl.kubernetes.io/last-applied-configuration:
                      {"apiVersion":"apps/v1","kind":"StatefulSet","metadata":{"annotations":{},"name":"example-nginx-statefulset","namespace":"default"},"spec"...
Replicas:           2 desired | 2 total
Update Strategy:    RollingUpdate
  Partition:        824642075976
Pods Status:        2 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=statefulset-nginx
  Containers:
   nginx-container:
    Image:        nginx
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Volume Claims:    <none>
Events:
  Type    Reason            Age    From                    Message
  ----    ------            ----   ----                    -------
  Normal  SuccessfulCreate  4m3s   statefulset-controller  create Pod example-nginx-statefulset-0 in StatefulSet example-nginx-statefulset successful
  Normal  SuccessfulCreate  4m1s   statefulset-controller  create Pod example-nginx-statefulset-1 in StatefulSet example-nginx-statefulset successful
  Normal  SuccessfulCreate  3m59s  statefulset-controller  create Pod example-nginx-statefulset-2 in StatefulSet example-nginx-statefulset successful
  Normal  SuccessfulCreate  3m5s   statefulset-controller  create Pod example-nginx-statefulset-3 in StatefulSet example-nginx-statefulset successful
  Normal  SuccessfulDelete  50s    statefulset-controller  delete Pod example-nginx-statefulset-3 in StatefulSet example-nginx-statefulset successful
  Normal  SuccessfulDelete  47s    statefulset-controller  delete Pod example-nginx-statefulset-2 in StatefulSet example-nginx-statefulset successful
shreyans_mulkutkar@cloudshell:~/my_utilities/statefulsets (smulkutk-project-1)$
```

### Deleting Statefulset
```
shreyans_mulkutkar@cloudshell:~/my_utilities/statefulsets (smulkutk-project-1)$ kubectl delete sts --all
statefulset.apps "example-nginx-statefulset" deleted
shreyans_mulkutkar@cloudshell:~/my_utilities/statefulsets (smulkutk-project-1)$ kubectl delete svc --all
service "kubernetes" deleted
service "statefulset-nginx" deleted
shreyans_mulkutkar@cloudshell:~/my_utilities/statefulsets (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/statefulsets (smulkutk-project-1)$ kubectl get all
NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.51.240.1   <none>        443/TCP   39s
```
