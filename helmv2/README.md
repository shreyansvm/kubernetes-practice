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

## Helm v2 command examples:
helm home:
```
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ helm home
/home/shreyans_mulkutkar/.helm
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$
```

helm init: 
- This will install Tiller to your running Kubernetes cluster. 
- It will also set up any necessary local configuration.
```
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ helm --help | grep init
To begin working with Helm, run the 'helm init' command:
        $ helm init
  init        Initialize Helm on both client and server
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$
```

helm version:
```
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm version
Client: &version.Version{SemVer:"v2.16.3", GitCommit:"1ee0254c86d4ed6887327dabed7aa7da29d7eb0d", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.16.3", GitCommit:"1ee0254c86d4ed6887327dabed7aa7da29d7eb0d", GitTreeState:"clean"}
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$
```

helm repo list:
```
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ helm repo list
NAME    URL
stable  https://kubernetes-charts.storage.googleapis.com
local   http://127.0.0.1:8879/charts
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$
```

helm repo update
- gets the latest information about charts from the respective chart repositories. Information is cached locally, where it is used by commands like ‘helm search’.
```
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ helm repo update local
Hang tight while we grab the latest from your chart repositories...
...Skip local chart repository
Update Complete.
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$
```

helm lint
```
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ helm lint my_utilities/helmv2/helm_example/
==> Linting my_utilities/helmv2/helm_example/
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, no failures
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$
```

'helm install' to install a chart-
```
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm install helm_example/
NAME:   ardent-wolf
LAST DEPLOYED: Thu Mar 12 16:54:03 2020
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Deployment
NAME                  AGE
nginx-deploy-example  0s

==> v1/Pod(related)
NAME                                   AGE
nginx-deploy-example-78c668d7fb-27fsn  0s
nginx-deploy-example-78c668d7fb-9wc4v  0s
nginx-deploy-example-78c668d7fb-pqf4b  0s

==> v1/Service
NAME               AGE
nginx-svc-example  0s


NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=helm_example,app.kubernetes.io/instance=ardent-wolf" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl port-forward $POD_NAME 8080:80

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$
```

helm list
```
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ helm list
NAME            REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
ardent-wolf     1               Thu Mar 12 16:54:03 2020        DEPLOYED        helm_example-0.1.0      1.0             default
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$
```

helm search 
```
# searches the Helm Hub, which comprises helm charts from dozens of different repositories
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ helm search hub
NAME                    CHART VERSION   APP VERSION     DESCRIPTION
stable/hubot            1.0.1           3.3.2           Hubot chatbot for Slack
stable/eventrouter      0.3.0           0.3             A Helm chart for eventruter (https://github.com/heptiolab...
stable/mercure          3.0.0           0.8.0           The Mercure hub allows to push data updates using the Mer...
stable/oauth2-proxy     2.2.2           4.0.0           A reverse proxy that provides authentication with Google,...
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ 

# searches the repositories that you have added to your local helm client (with helm repo add). 
# This search is done over local data, and no public network connection is needed.
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ helm search repo
NAME                    CHART VERSION   APP VERSION     DESCRIPTION
stable/jasperreports    7.0.10          7.2.0           DEPRECATED The JasperReports server can be used as a stan...
stable/artifactory      7.3.1           6.1.0           DEPRECATED Universal Repository Manager supporting all ma...
stable/artifactory-ha   0.4.1           6.2.0           DEPRECATED Universal Repository Manager supporting all ma...
stable/chartmuseum      2.8.0           0.11.0          Host your own Helm Chart Repository
stable/dmarc2logstash   1.2.0           1.0.3           Provides a POP3-polled DMARC XML report injector into Ela...
stable/pgadmin          1.2.3           4.18.0          DEPRECATED - moved to new repo, see source for new location
stable/satisfy          1.0.0           3.0.4           Composer repo hosting with Satisfy
stable/sentry           4.0.1           9.1.2           Sentry is a cross-platform crash reporting and aggregatio...
stable/sonatype-nexus   1.23.1          3.20.1-01       DEPRECATED - Sonatype Nexus is an open source repository ...
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$
```

helm inspect: inspects a chart and displays information
```
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ helm inspect --help

This command inspects a chart and displays information. It takes a chart reference
('stable/drupal'), a full path to a directory or packaged chart, or a URL.

Inspect prints the contents of the Chart.yaml file and the values.yaml file.
Usage:
  helm inspect [CHART] [flags]
  helm inspect [command]
Available Commands:
  chart       shows inspect chart
  readme      shows inspect readme
  values      shows inspect values
.
.

shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ helm --help | grep inspect
  inspect     Inspect a chart
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$
```

helm STATUS
```
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ helm status ardent-wolf
LAST DEPLOYED: Thu Mar 12 16:54:03 2020
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Deployment
NAME                  AGE
nginx-deploy-example  41m

==> v1/Pod(related)
NAME                                   AGE
nginx-deploy-example-78c668d7fb-27fsn  41m
nginx-deploy-example-78c668d7fb-9wc4v  41m
nginx-deploy-example-78c668d7fb-pqf4b  41m

==> v1/Service
NAME               AGE
nginx-svc-example  41m


NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=helm_example,app.kubernetes.io/instance=ardent-wolf" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl port-forward $POD_NAME 8080:80

shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$
```

helm get : Downloads the release
```
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ helm get ardent-wolf
REVISION: 1
RELEASED: Thu Mar 12 16:54:03 2020
CHART: helm_example-0.1.0
USER-SUPPLIED VALUES:
{}

COMPUTED VALUES:
affinity: {}
deploy-type: demo
deploy_name: nginx-deploy-example
fullnameOverride: ""
image:
  pullPolicy: IfNotPresent
  repository: nginx
  tag: stable
imagePullSecrets: []
ingress:
  annotations: {}
  enabled: false
  hosts:
  - host: chart-example.local
    paths: []
  tls: []
nameOverride: ""
nodeSelector: {}
podSecurityContext: {}
replicaCount: 3
resources: {}
securityContext: {}
service:
  port: 80
  targetPort: 8080
  type: ClusterIP
serviceAccount:
  create: true
  name: null
svc_name: nginx-svc-example
tolerations: []
user-type: test

HOOKS:
---
# ardent-wolf-helm_example-test-connection
apiVersion: v1
kind: Pod
metadata:
  name: "ardent-wolf-helm_example-test-connection"
  labels:
    app.kubernetes.io/name: helm_example
    helm.sh/chart: helm_example-0.1.0
    app.kubernetes.io/instance: ardent-wolf
    app.kubernetes.io/version: "1.0"
    app.kubernetes.io/managed-by: Tiller
  annotations:
    "helm.sh/hook": test-success
spec:
  containers:
    - name: wget
      image: busybox
      command: ['wget']
      args:  ['ardent-wolf-helm_example:80']
  restartPolicy: Never
MANIFEST:

---
# Source: helm_example/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc-example
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
---
# Source: helm_example/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy-example
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:stable
        ports:
        - containerPort: 80
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$
```

helm reset
```
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ helm reset --help

This command uninstalls Tiller (the Helm server-side component) from your
Kubernetes Cluster and optionally deletes local configuration in
$HELM_HOME (default ~/.helm/)

Usage:
  helm reset [flags]\
.
.

```

helm upgrade
```
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ cd my_utilities/helmv2
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ cd helm_example/
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2/helm_example (smulkutk-project-1)$ cat values.yaml | grep replicaCount
replicaCount: 3
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2/helm_example (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2/helm_example (smulkutk-project-1)$ cat Chart.yaml | grep version
version: 0.1.0
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2/helm_example (smulkutk-project-1)$

# For 'helm upgrade' example: 
#       Modify values.yaml to change replicaCount to 5
#       and change version in Charts.yaml to 0.2.0

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2/helm_example (smulkutk-project-1)$ cat values.yaml | grep replicaCount
replicaCount: 5
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2/helm_example (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2/helm_example (smulkutk-project-1)$ cat Chart.yaml | grep version
version: 0.2.0
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2/helm_example (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2/helm_example (smulkutk-project-1)$ helm list
NAME            REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
ardent-wolf     1               Thu Mar 12 16:54:03 2020        DEPLOYED        helm_example-0.1.0      1.0             default
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2/helm_example (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm upgrade -f helm_example/values.yaml ardent-wolf helm_example/
Release "ardent-wolf" has been upgraded.
LAST DEPLOYED: Thu Mar 12 18:04:23 2020
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Deployment
NAME                  AGE
nginx-deploy-example  70m

==> v1/Pod(related)
NAME                                   AGE
nginx-deploy-example-78c668d7fb-27fsn  70m
nginx-deploy-example-78c668d7fb-9wc4v  70m
nginx-deploy-example-78c668d7fb-dmt6k  0s
nginx-deploy-example-78c668d7fb-pqf4b  70m

==> v1/Service
NAME               AGE
nginx-svc-example  70m


NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=helm_example,app.kubernetes.io/instance=ardent-wolf" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl port-forward $POD_NAME 8080:80

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$

# REVISION has changed to '2'
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm list
NAME            REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
ardent-wolf     2               Thu Mar 12 18:04:23 2020        DEPLOYED        helm_example-0.2.0      1.0             default
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$

# Since we changed replicaCount to 5, it should get reflected in Pods and Deployments also.
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ kubectl get deploy,pods
NAME                                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.extensions/nginx-deploy-example   5/5     5            5           72m

NAME                                        READY   STATUS    RESTARTS   AGE
pod/nginx-deploy-example-78c668d7fb-27fsn   1/1     Running   0          72m
pod/nginx-deploy-example-78c668d7fb-2mvwp   1/1     Running   0          2m1s
pod/nginx-deploy-example-78c668d7fb-9wc4v   1/1     Running   0          72m
pod/nginx-deploy-example-78c668d7fb-dmt6k   1/1     Running   0          2m2s
pod/nginx-deploy-example-78c668d7fb-pqf4b   1/1     Running   0          72m
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$
```

helm history of release:
```
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm history ardent-wolf
REVISION        UPDATED                         STATUS          CHART                   APP VERSION     DESCRIPTION
1               Thu Mar 12 16:54:03 2020        SUPERSEDED      helm_example-0.1.0      1.0             Install complete
2               Thu Mar 12 18:04:23 2020        DEPLOYED        helm_example-0.2.0      1.0             Upgrade complete
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$
```

helm rollback
```
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm rollback --help

This command rolls back a release to a previous revision.

The first argument of the rollback command is the name of a release, and the
second is a revision (version) number. To see revision numbers, run
'helm history RELEASE'. If you'd like to rollback to the previous release use
'helm rollback [RELEASE] 0'.

Usage:
  helm rollback [flags] [RELEASE] [REVISION]
.
.

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm rollback ardent-wolf 1
Rollback was a success.
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm list
NAME            REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
ardent-wolf     3               Thu Mar 12 18:11:15 2020        DEPLOYED        helm_example-0.1.0      1.0             default
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm history ardent-wolf
REVISION        UPDATED                         STATUS          CHART                   APP VERSION     DESCRIPTION
1               Thu Mar 12 16:54:03 2020        SUPERSEDED      helm_example-0.1.0      1.0             Install complete
2               Thu Mar 12 18:04:23 2020        SUPERSEDED      helm_example-0.2.0      1.0             Upgrade complete
3               Thu Mar 12 18:11:15 2020        DEPLOYED        helm_example-0.1.0      1.0             Rollback to 1
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ kubectl get deploy
NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deploy-example   3/3     3            3           77m
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$

# you could again rollback to version 2 (with 5 replicaCount)\
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm rollback ardent-wolf 2
Rollback was a success.
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm list
NAME            REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
ardent-wolf     4               Thu Mar 12 18:15:18 2020        DEPLOYED        helm_example-0.2.0      1.0             default
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm history ardent-wolf
REVISION        UPDATED                         STATUS          CHART                   APP VERSION     DESCRIPTION
1               Thu Mar 12 16:54:03 2020        SUPERSEDED      helm_example-0.1.0      1.0             Install complete
2               Thu Mar 12 18:04:23 2020        SUPERSEDED      helm_example-0.2.0      1.0             Upgrade complete
3               Thu Mar 12 18:11:15 2020        SUPERSEDED      helm_example-0.1.0      1.0             Rollback to 1
4               Thu Mar 12 18:15:18 2020        DEPLOYED        helm_example-0.2.0      1.0             Rollback to 2
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ kubectl get deploy
NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deploy-example   5/5     5            5           82m
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$
```

helm fetch - Download a chart from a repository and (optionally) unpack it in local directory
```
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm --help | grep fetch
- helm fetch:     Download a chart to your local directory to view
  fetch       Download a chart from a repository and (optionally) unpack it in local directory
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm fetch stable/redis
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ ls -lrt
total 76
.
.
-rw-r--r-- 1 shreyans_mulkutkar shreyans_mulkutkar 31909 Mar 12 18:27 redis-10.5.7.tgz
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$

# Optionally, you can pass "--untar=true" flag to tell helm to untar the package after download. 
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm fetch stable/redis --untar=true
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ ls -lrt
total 80
.
.
-rw-r--r-- 1 shreyans_mulkutkar shreyans_mulkutkar 31909 Mar 12 18:27 redis-10.5.7.tgz
drwxr-xr-x 4 shreyans_mulkutkar shreyans_mulkutkar  4096 Mar 12 18:31 redis
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ cd redis/
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2/redis (smulkutk-project-1)$ tree
.
├── Chart.yaml
├── ci
│   ├── default-values.yaml
│   ├── dev-values.yaml
│   ├── extra-flags-values.yaml
│   ├── insecure-sentinel-values.yaml
│   ├── production-sentinel-values.yaml
│   ├── production-values.yaml
│   ├── redisgraph-module-values.yaml
│   └── redis-lib-values.yaml
├── README.md
├── templates
│   ├── configmap.yaml
│   ├── headless-svc.yaml
│   ├── health-configmap.yaml
│   ├── _helpers.tpl
│   ├── metrics-prometheus.yaml
│   ├── metrics-svc.yaml
│   ├── networkpolicy.yaml
│   ├── NOTES.txt
│   ├── prometheusrule.yaml
│   ├── psp.yaml
│   ├── redis-master-statefulset.yaml
│   ├── redis-master-svc.yaml
│   ├── redis-rolebinding.yaml
│   ├── redis-role.yaml
│   ├── redis-serviceaccount.yaml
│   ├── redis-slave-statefulset.yaml
│   ├── redis-slave-svc.yaml
│   ├── redis-with-sentinel-svc.yaml
│   └── secret.yaml
├── values-production.yaml
├── values.schema.json
└── values.yaml

2 directories, 32 files
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2/redis (smulkutk-project-1)$
```

Helm delete a given release -
```
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ helm --help | grep delete
  delete      Given a release name, delete the release from Kubernetes
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ helm list
NAME            REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
ardent-wolf     4               Thu Mar 12 18:15:18 2020        DEPLOYED        helm_example-0.2.0      1.0             default
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ helm delete ardent-wolf
release "ardent-wolf" deleted
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ helm list
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$

# Application Pods and other K8s objects are also deleted -
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ kubectl get deploy,svc,pod
NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.51.240.1   <none>        443/TCP   111m
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ helm history ardent-wolf
REVISION        UPDATED                         STATUS          CHART                   APP VERSION     DESCRIPTION
1               Thu Mar 12 16:54:03 2020        SUPERSEDED      helm_example-0.1.0      1.0             Install complete
2               Thu Mar 12 18:04:23 2020        SUPERSEDED      helm_example-0.2.0      1.0             Upgrade complete
3               Thu Mar 12 18:11:15 2020        SUPERSEDED      helm_example-0.1.0      1.0             Rollback to 1
4               Thu Mar 12 18:15:18 2020        DELETED         helm_example-0.2.0      1.0             Deletion complete
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$
```

Even after deletion, you can rollback to an older revision.
```
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ helm rollback ardent-wolf 1
Rollback was a success.
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ helm list
NAME            REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
ardent-wolf     5               Thu Mar 12 18:40:19 2020        DEPLOYED        helm_example-0.1.0      1.0             default
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ helm history ardent-wolf
REVISION        UPDATED                         STATUS          CHART                   APP VERSION     DESCRIPTION
1               Thu Mar 12 16:54:03 2020        SUPERSEDED      helm_example-0.1.0      1.0             Install complete
2               Thu Mar 12 18:04:23 2020        SUPERSEDED      helm_example-0.2.0      1.0             Upgrade complete
3               Thu Mar 12 18:11:15 2020        SUPERSEDED      helm_example-0.1.0      1.0             Rollback to 1
4               Thu Mar 12 18:15:18 2020        SUPERSEDED      helm_example-0.2.0      1.0             Deletion complete
5               Thu Mar 12 18:40:19 2020        DEPLOYED        helm_example-0.1.0      1.0             Rollback to 1
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ kubectl get deploy,svc,pod
NAME                                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.extensions/nginx-deploy-example   3/3     3            3           76s

NAME                        TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/kubernetes          ClusterIP   10.51.240.1   <none>        443/TCP   115m
service/nginx-svc-example   ClusterIP   10.51.252.5   <none>        80/TCP    76s

NAME                                        READY   STATUS    RESTARTS   AGE
pod/nginx-deploy-example-78c668d7fb-9nvpj   1/1     Running   0          76s
pod/nginx-deploy-example-78c668d7fb-p2ntw   1/1     Running   0          76s
pod/nginx-deploy-example-78c668d7fb-xk7sb   1/1     Running   0          76s
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$
```

helm serve
```
This command starts a local chart repository server that serves charts from a local directory.

The new server will provide HTTP access to a repository. By default, it will
scan all of the charts in '$HELM_HOME/repository/local' and serve those over
the local IPv4 TCP port (default '127.0.0.1:8879').

This command is intended to be used for educational and testing purposes only.
It is best to rely on a dedicated web server or a cloud-hosted solution like
Google Cloud Storage for production use.

See https://github.com/helm/helm/blob/master/docs/chart_repository.md#hosting-chart-repositories
for more information on hosting chart repositories in a production setting.

Usage:
  helm serve [flags]

Flags:
      --address string     Address to listen on (default "127.0.0.1:8879")
  -h, --help               help for serve
      --repo-path string   Local directory path from which to serve charts
      --url string         External URL of chart repository

Global Flags:
      --debug                           Enable verbose output
      --home string                     Location of your Helm config. Overrides $HELM_HOME (default "/home/shreyans_mulkutkar/.helm")
      --host string                     Address of Tiller. Overrides $HELM_HOST
      --kube-context string             Name of the kubeconfig context to use
      --kubeconfig string               Absolute path of the kubeconfig file to be used
      --tiller-connection-timeout int   The duration (in seconds) Helm will wait to establish a connection to Tiller (default 300)
      --tiller-namespace string         Namespace of Tiller (default "kube-system")
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$
```

## Changes in Helm v3 commands from v2. 
- init - installs Tiller and sets up local configuration has been removed.
- delete to delete a release from K8s has been replaced by ‘uninstall’ 
- fetch to download a chart to your local directory has been replaced by ‘pull’
- home has been removed.
- install: requires release name or --generate-name argument
- inspect to show a Chart is replaced by ‘show’
- serve has been removed.
- template: -x/--execute argument renamed to -s/--show-only
- upgrade: Added argument --history-max which limits the maximum number of revisions saved per release.
- reset to uninstalled Tiller and optioanlly delete local configuration has been removed.
