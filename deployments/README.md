# Notes on Deployment objects in K8s

## Usecases:
- To rollout a new Replicaset i.e. create new Pods
- To update the state of existing deployment
  - a new replicaset gets created. The pods from old replicaset gets slowed brought down and the new replicaset completely takes over.
- Rollback to earlier verison of deployment
- Scale up i.e. modify 'replicas' field
- Pause/Resuming deployments mid-way (after fixing bugs)
- Cleanup of old Replicaset that are not needed any more

Note: Use '--record' while applying a new deployment manifest i.e. 'kubectl apply -f file.yaml --record'. This will track all the changes to this deployyment and will be easy to track changes. 

### Important Fields in the Deployment Specification:
- Selector
- Strategy: How do you want the old pods to be replaced?
- parameters for Rolling Updates:
  - .spec.strategy.rollingUpdate.maxUnavailable
  - .spec.strategy.rollingUpdate.maxSurge
- Other useful fields:
  - progressDeadlineSeconds
  - minReadySeconds
  - rollbackTo
  - revisionHistoryLimit
  - paused

### Create new deployment
```
kubectl apply -f example_nginx_deployment.yaml --record

shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$ kubectl apply -f example_nginx_deployment.yaml --record 
deployment.apps/example-nginx-deployment created
shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$ kubectl get all
NAME                                            READY   STATUS    RESTARTS   AGE
pod/example-nginx-deployment-869df76898-9phhj   1/1     Running   0          15s
pod/example-nginx-deployment-869df76898-cjxlq   1/1     Running   0          15s
pod/example-nginx-deployment-869df76898-w4859   1/1     Running   0          15s

NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.51.240.1   <none>        443/TCP   3h16m

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/example-nginx-deployment   3/3     3            3           15s

NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/example-nginx-deployment-869df76898   3         3         3       16s
shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$
```

Note: 
- Scaling the deployment cannot be rolled-back i.e. revision will not get updated.
- Only changes to Pod template will trigger a new revision and later can be rolled back

Change image from 'nginx' to 'nginx:1.17'. Deployment updates revision. 

Note: this could be done using editing YAML file or using 'kubectl set image deployment/example-nginx-deployment nginx=nginx:1.17'

```
shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$ kubectl apply -f example_nginx_deployment_v2.yaml --record
deployment.apps/example-nginx-deployment configured
shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$ kubectl describe deployments
Name:                   example-nginx-deployment
Namespace:              default
CreationTimestamp:      Sat, 07 Mar 2020 10:52:22 -0800
Labels:                 app=nginx
                        run=example
Annotations:            deployment.kubernetes.io/revision: 3
.
.
Events:
  Type    Reason             Age                  From                   Message
  ----    ------             ----                 ----                   -------
  Normal  ScalingReplicaSet  7m39s (x2 over 13m)  deployment-controller  Scaled up replica set example-nginx-deployment-869df76898 to 3
  Normal  ScalingReplicaSet  2m38s                deployment-controller  Scaled up replica set example-nginx-deployment-b486c7d7c to 1
  Normal  ScalingReplicaSet  80s                  deployment-controller  Scaled down replica set example-nginx-deployment-b486c7d7c to 0
  Normal  ScalingReplicaSet  80s                  deployment-controller  Scaled up replica set example-nginx-deployment-7fc7c97575 to 1
  Normal  ScalingReplicaSet  76s (x2 over 8m9s)   deployment-controller  Scaled down replica set example-nginx-deployment-869df76898 to 2
  Normal  ScalingReplicaSet  76s                  deployment-controller  Scaled up replica set example-nginx-deployment-7fc7c97575 to 2
  Normal  ScalingReplicaSet  73s                  deployment-controller  Scaled down replica set example-nginx-deployment-869df76898 to 1
  Normal  ScalingReplicaSet  73s                  deployment-controller  Scaled up replica set example-nginx-deployment-7fc7c97575 to 3
  Normal  ScalingReplicaSet  70s                  deployment-controller  Scaled down replica set example-nginx-deployment-869df76898 to 0
shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$
```
The different revisions can be seen as follows:
```
shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$ kubectl rollout status deployment example-nginx-deployment
deployment "example-nginx-deployment" successfully rolled out
shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$ kubectl rollout history deployment example-nginx-deployment
deployment.extensions/example-nginx-deployment
REVISION  CHANGE-CAUSE
1         kubectl apply --filename=example_nginx_deployment.yaml --record=true
2         kubectl apply --filename=example_nginx_deployment_v2.yaml --record=true
3         kubectl apply --filename=example_nginx_deployment_v2.yaml --record=true

shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$
```

### Rollback deployment 
Rollback to older revision 1 (i..e container with 'nginx' image)
```
kubectl rollout undo deployment example-nginx-deployment --to-revision=1

shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$ kubectl rollout undo deployment example-nginx-deployment --to-revision=1
deployment.extensions/example-nginx-deployment rolled back
shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$ kubectl rollout history deployment example-nginx-deployment 
deployment.extensions/example-nginx-deployment
REVISION  CHANGE-CAUSE
2         kubectl apply --filename=example_nginx_deployment_v2.yaml --record=true
3         kubectl apply --filename=example_nginx_deployment_v2.yaml --record=true
4         kubectl apply --filename=example_nginx_deployment.yaml --record=true

shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$ kubectl describe deployments example-nginx-deployment
Name:                   example-nginx-deployment
Namespace:              default
CreationTimestamp:      Sat, 07 Mar 2020 10:52:22 -0800
Labels:                 app=nginx
                        run=example
Annotations:            deployment.kubernetes.io/revision: 4
.
.
Pod Template:
  Labels:  app=nginx
           run=example
  Containers:
   nginx:
    Image:        nginx
    Port:         80/TCP
.
.
OldReplicaSets:  <none>
NewReplicaSet:   example-nginx-deployment-869df76898 (3/3 replicas created)
Events:
  Type    Reason             Age                  From                   Message
  ----    ------             ----                 ----                   -------
  Normal  ScalingReplicaSet  12m (x2 over 18m)    deployment-controller  Scaled up replica set example-nginx-deployment-869df76898 to 3
  Normal  ScalingReplicaSet  7m9s                 deployment-controller  Scaled up replica set example-nginx-deployment-b486c7d7c to 1
  Normal  ScalingReplicaSet  5m51s                deployment-controller  Scaled down replica set example-nginx-deployment-b486c7d7c to 0
  Normal  ScalingReplicaSet  5m51s                deployment-controller  Scaled up replica set example-nginx-deployment-7fc7c97575 to 1
  Normal  ScalingReplicaSet  5m47s (x2 over 12m)  deployment-controller  Scaled down replica set example-nginx-deployment-869df76898 to 2
  Normal  ScalingReplicaSet  5m47s                deployment-controller  Scaled up replica set example-nginx-deployment-7fc7c97575 to 2
  Normal  ScalingReplicaSet  5m44s                deployment-controller  Scaled down replica set example-nginx-deployment-869df76898 to 1
  Normal  ScalingReplicaSet  5m44s                deployment-controller  Scaled up replica set example-nginx-deployment-7fc7c97575 to 3
  Normal  ScalingReplicaSet  5m41s                deployment-controller  Scaled down replica set example-nginx-deployment-869df76898 to 0
  Normal  ScalingReplicaSet  45s (x6 over 50s)    deployment-controller  (combined from similar events): Scaled down replica set example-nginx-deployment-7fc7c97575 to 0
shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$
```

### Pausing and Resume deployments
- When paused, any changes to Pod template will not have any impact on the current deployment. 
- When resumed, changes will reflect in a new revision. 
```
shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$ kubectl rollout pause deployment example-nginx-deployment
deployment.extensions/example-nginx-deployment paused
shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$ kubectl rollout resume deployment example-nginx-deployment
deployment.extensions/example-nginx-deployment resumed
shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$
```

### Clean-up Policy
- By default, any changes to Pod template triggers new revision.
- Each revision (i.e. each change to Pod template) will have a new replicaset
- '.spec.revisionHistoryLimit' controls how many such revisions can be kept. Thus, revisionHistory helps in garbage collecting the old ReplicaSet. 

### Scaling Deployments
Note: 
- scaling deployment does not change Pod template i.e. doesn't trigger new revision
- Thus cannot be rolled-back
```
kubectl scale deployment example-nginx-deployment --replicas=4

shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$ kubectl get deployments
NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
example-nginx-deployment   3/3     3            3           27m
shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$ kubectl scale deployment example-nginx-deployment --replicas=4
deployment.extensions/example-nginx-deployment scaled
shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$ kubectl get deployments
NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
example-nginx-deployment   4/4     4            4           27m
```
### Scaling deployment using HorizontalPodAutoscalar (HPA)
Example -
```
kubectl autoscale deployment example-nginx-deployment --min=3 --max=6 --cpu-percent=50

shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$ kubectl get all
NAME                                            READY   STATUS    RESTARTS   AGE
pod/example-nginx-deployment-869df76898-t757q   1/1     Running   0          13m
pod/example-nginx-deployment-869df76898-v9zk9   1/1     Running   0          13m
pod/example-nginx-deployment-869df76898-vx4qx   1/1     Running   0          13m
pod/example-nginx-deployment-869df76898-zw7gd   1/1     Running   0          3m33s

NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.51.240.1   <none>        443/TCP   3h46m

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/example-nginx-deployment   4/4     4            4           30m

NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/example-nginx-deployment-7fc7c97575   0         0         0       18m
replicaset.apps/example-nginx-deployment-869df76898   4         4         4       30m
replicaset.apps/example-nginx-deployment-b486c7d7c    0         0         0       19m

NAME                                                           REFERENCE                             TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/example-nginx-deployment   Deployment/example-nginx-deployment   0%/50%    3         6         4          24s
shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$ kubectl describe hpa
Name:                     example-nginx-deployment
Namespace:                default
Labels:                   <none>
Annotations:              autoscaling.alpha.kubernetes.io/conditions:
                            [{"type":"AbleToScale","status":"True","lastTransitionTime":"2020-03-07T19:22:55Z","reason":"ScaleDownStabilized","message":"recent recomm...
                          autoscaling.alpha.kubernetes.io/current-metrics:
                            [{"type":"Resource","resource":{"name":"cpu","currentAverageUtilization":0,"currentAverageValue":"0"}}]
CreationTimestamp:        Sat, 07 Mar 2020 11:22:39 -0800
Reference:                Deployment/example-nginx-deployment
Target CPU utilization:   50%
Current CPU utilization:  0%
Min replicas:             3
Max replicas:             6
Deployment pods:          4 current / 4 desired
Events:                   <none>
shreyans_mulkutkar@cloudshell:~/my_utilities/deployments (smulkutk-project-1)$
  
```

### Proportional Scaling
- During rolling deployments i.e. while transitioning into new revision, there will be Pods in both Old and New version.
- We could use Proportional Scaling option to scale Pods in both Replicaset.
- For more details visit: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#proportional-scaling

