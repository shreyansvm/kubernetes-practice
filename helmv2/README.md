# Notes on Helmv2

## Helm installation
```
./install_helm.sh

shreyans_mulkutkar@cloudshell:~/my_utilities/helm (smulkutk-project-1)$ cat install_helm.sh
#!/usr/bin/env bash

### HELM_v2 installation

echo "install helm"
# installs helm with bash commands for easier command line integration
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
# add a service account within a namespace to segregate tiller
kubectl --namespace kube-system create sa tiller
# create a cluster role binding for tiller
kubectl create clusterrolebinding tiller \
    --clusterrole cluster-admin \
    --serviceaccount=kube-system:tiller

echo "initialize helm"
# initialized helm within the tiller service account
helm init --service-account tiller
# updates the repos for Helm repo integration
helm repo update

echo "verify helm"
# verify that helm is installed in the cluster
kubectl get deploy,svc tiller-deploy -n kube-system
```

After helm installation, version can be seen as follows:
```
shreyans_mulkutkar@cloudshell:~/my_utilities/helm (smulkutk-project-1)$ helm version
Client: &version.Version{SemVer:"v2.16.3", GitCommit:"1ee0254c86d4ed6887327dabed7aa7da29d7eb0d", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.16.3", GitCommit:"1ee0254c86d4ed6887327dabed7aa7da29d7eb0d", GitTreeState:"clean"}
shreyans_mulkutkar@cloudshell:~/my_utilities/helm (smulkutk-project-1)$
```


## Create a new chart -
```
shreyans_mulkutkar@cloudshell:~/my_utilities/helm (smulkutk-project-1)$ helm create helm_example
Creating helm_example
shreyans_mulkutkar@cloudshell:~/my_utilities/helm (smulkutk-project-1)$ ls
helm_example  install_helm.sh  logs.txt  redis_install_via_helm.sh  uninstall_helm.sh
shreyans_mulkutkar@cloudshell:~/my_utilities/helm (smulkutk-project-1)$ cd helm_example/
shreyans_mulkutkar@cloudshell:~/my_utilities/helm/helm_example (smulkutk-project-1)$ tree
.
├── charts
├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   ├── _helpers.tpl
│   ├── ingress.yaml
│   ├── NOTES.txt
│   ├── serviceaccount.yaml
│   ├── service.yaml
│   └── tests
│       └── test-connection.yaml
└── values.yaml

3 directories, 9 files
shreyans_mulkutkar@cloudshell:~/my_utilities/helm/helm_example (smulkutk-project-1)$
```

### Create a simple nginx deployment and nginx service YAML files
Add simple details to values/values.yaml file and later reference it under deployment.yaml and service.yaml
Delete files that are not required (in my case, I got rid of serviceaccount.yaml and ingress.yaml)
```
shreyans_mulkutkar@cloudshell:~/my_utilities/helm (smulkutk-project-1)$ cd helm_example/
shreyans_mulkutkar@cloudshell:~/my_utilities/helm/helm_example (smulkutk-project-1)$ tree
.
├── charts
├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   ├── _helpers.tpl
│   ├── NOTES.txt
│   ├── service.yaml
│   └── tests
│       └── test-connection.yaml
└── values.yaml

3 directories, 7 files
```

### Dry-run your charts to see if there are any errors.
```
shreyans_mulkutkar@cloudshell:~/my_utilities/helm (smulkutk-project-1)$ helm install --dry-run helm_example/
NAME:   existing-seahorse
shreyans_mulkutkar@cloudshell:~/my_utilities/helm (smulkutk-project-1)$
```

### Once --dry-run is successful, go ahead and intall the 'helm_example' charts
```
shreyans_mulkutkar@cloudshell:~/my_utilities/helm (smulkutk-project-1)$ helm install helm_example/
NAME:   nonexistent-panda
LAST DEPLOYED: Wed Mar 11 21:54:05 2020
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Deployment
NAME                  AGE
nginx-deploy-example  1s

==> v1/Pod(related)
NAME                                   AGE
nginx-deploy-example-78c668d7fb-75xnp  0s
nginx-deploy-example-78c668d7fb-s45fm  0s
nginx-deploy-example-78c668d7fb-vd42x  0s
==> v1/Service
NAME               AGE
nginx-svc-example  1s


NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=helm_example,app.kubernetes.io/instance=nonexistent-panda" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl port-forward $POD_NAME 8080:80

shreyans_mulkutkar@cloudshell:~/my_utilities/helm (smulkutk-project-1)$
```

### Check if nginx pods, deployment and service is running as expected. 
```
shreyans_mulkutkar@cloudshell:~/my_utilities/helm (smulkutk-project-1)$ kubectl get all
NAME                                        READY   STATUS    RESTARTS   AGE
pod/nginx-deploy-example-78c668d7fb-75xnp   1/1     Running   0          101s
pod/nginx-deploy-example-78c668d7fb-s45fm   1/1     Running   0          101s
pod/nginx-deploy-example-78c668d7fb-vd42x   1/1     Running   0          101s

NAME                        TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/kubernetes          ClusterIP   10.51.240.1    <none>        443/TCP   90m
service/nginx-svc-example   ClusterIP   10.51.248.99   <none>        80/TCP    102s

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deploy-example   3/3     3            3           102s

NAME                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-deploy-example-78c668d7fb   3         3         3       101s
shreyans_mulkutkar@cloudshell:~/my_utilities/helm (smulkutk-project-1)$
```

## Use 'helm list' to list all the releases. 
```
shreyans_mulkutkar@cloudshell:~/my_utilities/helm (smulkutk-project-1)$ helm list
NAME                    REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
nonexistent-panda       1               Wed Mar 11 21:54:05 2020        DEPLOYED        helm_example-0.1.0      1.0             default
shreyans_mulkutkar@cloudshell:~/my_utilities/helm (smulkutk-project-1)$
```

### Available Helm repositories can be listed using 'helm repo list'
```
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm repo list
NAME    URL
stable  https://kubernetes-charts.storage.googleapis.com
local   http://127.0.0.1:8879/charts
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$
```

## Use 'helm delete' to a specific chart
```
shreyans_mulkutkar@cloudshell:~/my_utilities (smulkutk-project-1)$ helm list
NAME                    REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
nonexistent-panda       1               Wed Mar 11 21:54:05 2020        DEPLOYED        helm_example-0.1.0      1.0             default
shreyans_mulkutkar@cloudshell:~/my_utilities (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities (smulkutk-project-1)$ helm delete nonexistent-panda
release "nonexistent-panda" deleted
shreyans_mulkutkar@cloudshell:~/my_utilities (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities (smulkutk-project-1)$ kubectl get all
NAME                                        READY   STATUS        RESTARTS   AGE
pod/nginx-deploy-example-78c668d7fb-s45fm   0/1     Terminating   0          5m48s

NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.51.240.1   <none>        443/TCP   94m
shreyans_mulkutkar@cloudshell:~/my_utilities (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities (smulkutk-project-1)$ kubectl get all
NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.51.240.1   <none>        443/TCP   94m
shreyans_mulkutkar@cloudshell:~/my_utilities (smulkutk-project-1)$
```

rollback an upgrade to your Helm Chart to a previous chart can also be done -
```
helm rollback
```
