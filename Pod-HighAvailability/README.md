# Example for achieving Pod Redundancy (Active-Standby)

You may want to have multiple Pods in N:K or N+ redundancy mode, where N=number of active pods and K=number of standby pods. 

This tutorial uses the Leader Election logic described here -https://github.com/kubernetes-retired/contrib/tree/master/election

### Pod details -
In this demo, I'm deploying 2 NGINX Pods. Each ‘nginx-ha’ Pod has two containers – 
* ‘nginx-ha-container’ and 
* ‘leader-election-container’ – provides a webserver like capability on any address that you provide. In this example, I’m passing “http=0.0.0.0:4040” as arguments in the container manifest. 

The 'leader-election-container’ acts like a sidecar for the main 'nginx' application container. 

The ‘nginx-ha-container’ finds out who is the master by accessing http://localhost:4040, which returns a simple JSON object that contains the name of the current master. 
```
.
.
        containers:
            - name: nginx-ha-container
              image: nginx
              ports:
              - containerPort: 80
              lifecycle:
                postStart:
                    exec:
                        command: ["sh", "-c", "apt-get update; apt-get install -y curl;"]
              readinessProbe:
                exec:
                    command: ["/bin/sh", "-c", "curl -v --silent http://localhost:4040/ 2>&1 | grep $HOSTNAME "]
                initialDelaySeconds: 5
                periodSeconds: 5
            - name: leader-election-container
              image: "k8s.gcr.io/leader-elector:0.5"
              args:
              - --election=example
              - --http=0.0.0.0:4040
              imagePullPolicy: IfNotPresent
              ports:
              - containerPort: 4040
.
.
```

### Demo -

Using this sample K8s [manifest file](https://github.com/shreyansvm/kubernetes-practice/blob/master/nginxPodHighAvailabilityDemo.yml) create -
* 'nginx-ha' Namespace
* 'nginx-ha-serviceaccount' ServiceAccount in the above namespace
* 'nginx-ha-clusterrole' ClusterRole objec to allow access to 'endpoints'
* 'nginx-ha-clusterrolebinding' ClusterRoleBinding
*  and finally 'nginx-ha' Deployment with 2 Replicas of 'nginx-ha' Pod. As mentioned earlier, each Pod has two containers – 
    * ‘nginx-ha-container’ and 
    * ‘leader-election-container’ – provides a webserver like capability on any address that you provide. In this example, I’m passing “http=0.0.0.0:4040” as arguments in the container manifest. 


Even though 2 Pods running, replicaSet confirms that only 1 is 'Ready' i.e. only master Pod is active/ready. 
```
shreyans_mulkutkar@cloudshell:~$ kubectl get deploy,rs,pod -n nginx-ha -o wide
NAME                             READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS                                     IMAGES                                SELECTOR
deployment.extensions/nginx-ha   1/2     2            1           16s   nginx-ha-container,leader-election-container   nginx,k8s.gcr.io/leader-elector:0.5   app=nginx-ha

NAME                                        DESIRED   CURRENT   READY   AGE   CONTAINERS                                     IMAGES                                SELECTOR
replicaset.extensions/nginx-ha-5d54646fdb   2         2         1       16s   nginx-ha-container,leader-election-container   nginx,k8s.gcr.io/leader-elector:0.5   app=nginx-ha,pod-template-hash=5d54646fdb

NAME                            READY   STATUS    RESTARTS   AGE   IP          NODE                                            NOMINATED NODE   READINESS GATES
pod/nginx-ha-5d54646fdb-8sbvd   2/2     Running   0          16s   10.36.2.9   gke-pod-ha-cluster-default-pool-a1970269-6sgt   <none>           <none>
pod/nginx-ha-5d54646fdb-fnw49   1/2     Running   0          16s   10.36.1.9   gke-pod-ha-cluster-default-pool-a1970269-m75j   <none>           <none>
shreyans_mulkutkar@cloudshell:~$

```

‘example’ is passed as an argument to the ‘leader-election-container’. 
You can also see the holder identity of this endpoint i.e. the current master pod. 
```
shreyans_mulkutkar@cloudshell:~$ kubectl get endpoints
NAME         ENDPOINTS          AGE
example      <none>             39s
kubernetes   35.230.23.15:443   11h
shreyans_mulkutkar@cloudshell:~$ 

shreyans_mulkutkar@cloudshell:~$ kubectl get endpoints example -o yaml
apiVersion: v1
kind: Endpoints
metadata:
  annotations:
    control-plane.alpha.kubernetes.io/leader: '{"holderIdentity":"nginx-ha-5d54646fdb-8sbvd","leaseDurationSeconds":10,"acquireTime":"2020-02-17T05:35:12Z","renewTime":"2020-02-17T05:36:00Z","leaderTransitions":0}'
  creationTimestamp: "2020-02-17T05:35:12Z"
  name: example
  namespace: default
  resourceVersion: "168692"
  selfLink: /api/v1/namespaces/default/endpoints/example
  uid: 44b218d9-5147-11ea-87e6-42010a8a00bf
shreyans_mulkutkar@cloudshell:~$
```


The **'leader-election-container'** in both Pods points to the same master.

Pod-1:
```
shreyans_mulkutkar@cloudshell:~$ kubectl logs pod/nginx-ha-5d54646fdb-8sbvd -c leader-election-container -n nginx-ha -f
is the leader
I0217 05:35:12.569830       7 leaderelection.go:215] sucessfully acquired lease default/example
nginx-ha-5d54646fdb-8sbvd is the leader
.
.
shreyans_mulkutkar@cloudshell:~$
```

Pod-2:
```
shreyans_mulkutkar@cloudshell:~$ kubectl logs pod/nginx-ha-5d54646fdb-fnw49 -c leader-election-container -n nginx-ha -f
nginx-ha-5d54646fdb-8sbvd is the leader
I0217 05:35:13.498312       7 leaderelection.go:296] lock is held by nginx-ha-5d54646fdb-8sbvd and has not yet expired
I0217 05:35:17.815812       7 leaderelection.go:296] lock is held by nginx-ha-5d54646fdb-8sbvd and has not yet expired
.
.
shreyans_mulkutkar@cloudshell:~$
```

**Another way to find the current master** --

Pod-1:
```
shreyans_mulkutkar@cloudshell:~$ kubectl exec -ti nginx-ha-5d54646fdb-8sbvd -n nginx-ha -- /bin/bash
Defaulting container name to nginx-ha-container.
Use 'kubectl describe pod/nginx-ha-5d54646fdb-8sbvd -n nginx-ha' to see all of the containers in this pod.
root@nginx-ha-5d54646fdb-8sbvd:/# curl -v --silent http://localhost:4040/
.
.
> GET / HTTP/1.1
> Host: localhost:4040
> User-Agent: curl/7.64.0
> Accept: */*
>
< HTTP/1.1 200 OK
< Date: Mon, 17 Feb 2020 05:37:29 GMT
< Content-Length: 36
< Content-Type: text/plain; charset=utf-8
<
* Connection #0 to host localhost left intact
{"name":"nginx-ha-5d54646fdb-8sbvd"}
root@nginx-ha-5d54646fdb-8sbvd:/# exit
```

Pod-2:
```
shreyans_mulkutkar@cloudshell:~$ kubectl exec -ti nginx-ha-5d54646fdb-fnw49 -n nginx-ha -- /bin/bash
Defaulting container name to nginx-ha-container.
Use 'kubectl describe pod/nginx-ha-5d54646fdb-8sbvd -n nginx-ha' to see all of the containers in this pod.
root@nginx-ha-5d54646fdb-fnw49:/# curl -v --silent http://localhost:4040/
.
.
> GET / HTTP/1.1
> Host: localhost:4040
> User-Agent: curl/7.64.0
> Accept: */*
>
< HTTP/1.1 200 OK
< Date: Mon, 17 Feb 2020 05:38:11 GMT
< Content-Length: 36
< Content-Type: text/plain; charset=utf-8
<
* Connection #0 to host localhost left intact
{"name":"nginx-ha-5d54646fdb-8sbvd"}
root@nginx-ha-5d54646fdb-fnw49:/#
```

### Current Master/Active Pod dies -
killing Pod-1 (current master - ```nginx-ha-7875bfffff-fxfj7``` ), spwan’s another Pod as the ReplicaSet=2. But now the current master is pointed to the original standby/slave Pod-2 ```nginx-ha-7875bfffff-p4pcp``` . 

Delete Pod-1 (current master):
```
shreyans_mulkutkar@cloudshell:~$ kubectl delete pod/nginx-ha-5d54646fdb-8sbvd -n nginx-ha
pod "nginx-ha-5d54646fdb-8sbvd" deleted
shreyans_mulkutkar@cloudshell:~$
```

ReplicaSet is back to 2, but **only 1 is Ready** (Pod-3 ```nginx-ha-5d54646fdb-mwp5b``` gets spwaned.)

```
shreyans_mulkutkar@cloudshell:~$ kubectl get deploy,rs,pod -n nginx-ha -o wide
NAME                             READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS                                     IMAGES                                SELECTOR
deployment.extensions/nginx-ha   1/2     2            1           8m36s   nginx-ha-container,leader-election-container   nginx,k8s.gcr.io/leader-elector:0.5   app=nginx-ha

NAME                                        DESIRED   CURRENT   READY   AGE     CONTAINERS                                     IMAGES                                SELECTOR
replicaset.extensions/nginx-ha-5d54646fdb   2         2         1       8m36s   nginx-ha-container,leader-election-container   nginx,k8s.gcr.io/leader-elector:0.5   app=nginx-ha,pod-template-hash=5d54646fdb

NAME                            READY   STATUS    RESTARTS   AGE     IP           NODE                                            NOMINATED NODE   READINESS GATES
pod/nginx-ha-5d54646fdb-fnw49   1/2     Running   0          8m36s   10.36.1.9    gke-pod-ha-cluster-default-pool-a1970269-m75j   <none>           <none>
pod/nginx-ha-5d54646fdb-mwp5b   2/2     Running   0          60s     10.36.2.10   gke-pod-ha-cluster-default-pool-a1970269-6sgt   <none>           <none>
shreyans_mulkutkar@cloudshell:~$
```

#### Pod-3 takes over as the new Master : 

Pod-2 sees that the lock is currently held by Pod-3 ```nginx-ha-5d54646fdb-mwp5b``` current Master -
```
shreyans_mulkutkar@cloudshell:~$ kubectl logs pod/nginx-ha-5d54646fdb-fnw49 -c leader-election-container -n nginx-ha -f
nginx-ha-5d54646fdb-8sbvd is the leader
.
.
I0217 05:43:12.003229       7 leaderelection.go:296] lock is held by nginx-ha-5d54646fdb-8sbvd and has not yet expired
I0217 05:43:15.885226       7 leaderelection.go:296] lock is held by nginx-ha-5d54646fdb-8sbvd and has not yet expired
I0217 05:43:20.189387       7 leaderelection.go:296] lock is held by nginx-ha-5d54646fdb-mwp5b and has not yet expired
I0217 05:43:22.771665       7 leaderelection.go:296] lock is held by nginx-ha-5d54646fdb-mwp5b and has not yet expired
I0217 05:43:27.812663       7 leaderelection.go:296] lock is held by nginx-ha-5d54646fdb-mwp5b and has not yet expired
.
.
shreyans_mulkutkar@cloudshell:~$
```

EndPoint **‘holderIdentity’** also changes to the current master Pod.
```
shreyans_mulkutkar@cloudshell:~$ kubectl get endpoints example -o yaml
apiVersion: v1
kind: Endpoints
metadata:
  annotations:
    control-plane.alpha.kubernetes.io/leader: '{"holderIdentity":"nginx-ha-5d54646fdb-mwp5b","leaseDurationSeconds":10,"acquireTime":"2020-02-17T05:43:16Z","renewTime":"2020-02-17T05:47:02Z","leaderTransitions":0}'
  creationTimestamp: "2020-02-17T05:35:12Z"
  name: example
  namespace: default
  resourceVersion: "171310"
  selfLink: /api/v1/namespaces/default/endpoints/example
  uid: 44b218d9-5147-11ea-87e6-42010a8a00bf
shreyans_mulkutkar@cloudshell:~$
```

### Current Slave/Standby Pod dies -

killing Pod-2 (current slave/standby) ```nginx-ha-5d54646fdb-fnw49```
```
shreyans_mulkutkar@cloudshell:~$ kubectl delete pod nginx-ha-5d54646fdb-fnw49 -n nginx-ha
pod "nginx-ha-5d54646fdb-fnw49" deleted
shreyans_mulkutkar@cloudshell:~$
```

New Pod gets spwaned to maintain the replicaSet=2
```
shreyans_mulkutkar@cloudshell:~$ kubectl get deploy,rs,pod -n nginx-ha -o wide
NAME                             READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS                                     IMAGES                                SELECTOR
deployment.extensions/nginx-ha   1/2     2            1           30m   nginx-ha-container,leader-election-container   nginx,k8s.gcr.io/leader-elector:0.5   app=nginx-ha

NAME                                        DESIRED   CURRENT   READY   AGE   CONTAINERS                                     IMAGES                                SELECTOR
replicaset.extensions/nginx-ha-5d54646fdb   2         2         1       30m   nginx-ha-container,leader-election-container   nginx,k8s.gcr.io/leader-elector:0.5   app=nginx-ha,pod-template-hash=5d54646fdb

NAME                            READY   STATUS        RESTARTS   AGE   IP           NODE                                            NOMINATED NODE   READINESS GATES
pod/nginx-ha-5d54646fdb-fnw49   1/2     Terminating   0          30m   10.36.1.9    gke-pod-ha-cluster-default-pool-a1970269-m75j   <none>           <none>
pod/nginx-ha-5d54646fdb-kplfk   1/2     Running       0          11s   10.36.1.10   gke-pod-ha-cluster-default-pool-a1970269-m75j   <none>           <none>
pod/nginx-ha-5d54646fdb-mwp5b   2/2     Running       0          22m   10.36.2.10   gke-pod-ha-cluster-default-pool-a1970269-6sgt   <none>           <none>
shreyans_mulkutkar@cloudshell:~$
```

#### Pod-3 (older master) ```nginx-ha-5d54646fdb-mwp5b``` stays Master
```
shreyans_mulkutkar@cloudshell:~$ kubectl get deploy,rs,pod -n nginx-ha -o wide
NAME                             READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS                                     IMAGES                                SELECTOR
deployment.extensions/nginx-ha   1/2     2            1           31m   nginx-ha-container,leader-election-container   nginx,k8s.gcr.io/leader-elector:0.5   app=nginx-ha

NAME                                        DESIRED   CURRENT   READY   AGE   CONTAINERS                                     IMAGES                                SELECTOR
replicaset.extensions/nginx-ha-5d54646fdb   2         2         1       31m   nginx-ha-container,leader-election-container   nginx,k8s.gcr.io/leader-elector:0.5   app=nginx-ha,pod-template-hash=5d54646fdb

NAME                            READY   STATUS    RESTARTS   AGE   IP           NODE                                            NOMINATED NODE   READINESS GATES
pod/nginx-ha-5d54646fdb-kplfk   1/2     Running   0          50s   10.36.1.10   gke-pod-ha-cluster-default-pool-a1970269-m75j   <none>           <none>
pod/nginx-ha-5d54646fdb-mwp5b   2/2     Running   0          23m   10.36.2.10   gke-pod-ha-cluster-default-pool-a1970269-6sgt   <none>           <none>
shreyans_mulkutkar@cloudshell:~$
```

New Pod’s logs also point that current master is ```nginx-ha-5d54646fdb-mwp5b```
```
shreyans_mulkutkar@cloudshell:~$ kubectl logs pod/nginx-ha-5d54646fdb-kplfk -c leader-election-container -n nginx-ha -f
nginx-ha-5d54646fdb-mwp5b is the leader
I0217 06:05:24.811083       7 leaderelection.go:296] lock is held by nginx-ha-5d54646fdb-mwp5b and has not yet expired
I0217 06:05:29.129968       7 leaderelection.go:296] lock is held by nginx-ha-5d54646fdb-mwp5b and has not yet expired
.
.
shreyans_mulkutkar@cloudshell:~$
```

EndPoint ‘holderIdentity’ remains un-changed i.e. points to current Master ```nginx-ha-5d54646fdb-mwp5b```. 
```
shreyans_mulkutkar@cloudshell:~$ kubectl get endpoints example -o yaml
apiVersion: v1
kind: Endpoints
metadata:
  annotations:
    control-plane.alpha.kubernetes.io/leader: '{"holderIdentity":"nginx-ha-5d54646fdb-mwp5b","leaseDurationSeconds":10,"acquireTime":"2020-02-17T05:43:16Z","renewTime":"2020-02-17T06:06:35Z","leaderTransitions":0}'
  creationTimestamp: "2020-02-17T05:35:12Z"
  name: example
  namespace: default
  resourceVersion: "175942"
  selfLink: /api/v1/namespaces/default/endpoints/example
  uid: 44b218d9-5147-11ea-87e6-42010a8a00bf
shreyans_mulkutkar@cloudshell:~$
```


## Acknowledgments

* https://github.com/kubernetes-retired/contrib/tree/master/election

