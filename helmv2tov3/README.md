# Notes on Helm 2 to 3 migration
Using helm-2to3 migration utility provided by Helm:
https://github.com/helm/helm-2to3

## Let's start with installing a simple nginx release using Helm v2
### Install Helm v2
```
shreyans_mulkutkar@cloudshell:~ (smulkutk-project-1)$ cd my_utilities/helmv2
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ ./install_helm.sh
install helm
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7150  100  7150    0     0  34300      0 --:--:-- --:--:-- --:--:-- 34375
Helm v2.16.3 is available. Changing from version v2.14.1.
Downloading https://get.helm.sh/helm-v2.16.3-linux-amd64.tar.gz
Preparing to install helm and tiller into /usr/local/bin
helm installed into /usr/local/bin/helm
tiller installed into /usr/local/bin/tiller
Run 'helm init' to configure helm.
serviceaccount/tiller created
clusterrolebinding.rbac.authorization.k8s.io/tiller created
initialize helm
Creating /home/shreyans_mulkutkar/.helm
Creating /home/shreyans_mulkutkar/.helm/repository
Creating /home/shreyans_mulkutkar/.helm/repository/cache
Creating /home/shreyans_mulkutkar/.helm/repository/local
Creating /home/shreyans_mulkutkar/.helm/plugins
Creating /home/shreyans_mulkutkar/.helm/starters
Creating /home/shreyans_mulkutkar/.helm/cache/archive
Creating /home/shreyans_mulkutkar/.helm/repository/repositories.yaml
Adding stable repo with URL: https://kubernetes-charts.storage.googleapis.com
Adding local repo with URL: http://127.0.0.1:8879/charts
$HELM_HOME has been configured at /home/shreyans_mulkutkar/.helm.
Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.

Please note: by default, Tiller is deployed with an insecure 'allow unauthenticated users' policy.
To prevent this, run `helm init` with the --tiller-tls-verify flag.
For more information on securing your installation see: https://docs.helm.sh/using_helm/#securing-your-helm-installation
Hang tight while we grab the latest from your chart repositories...
...Skip local chart repository
...Successfully got an update from the "stable" chart repository
Update Complete.
verify helm
NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.extensions/tiller-deploy   0/1     1            0           3s

NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)     AGE
service/tiller-deploy   ClusterIP   10.51.240.136   <none>        44134/TCP   2s
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$
```


### Helm v2.16.3 is installed
```
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm version
Client: &version.Version{SemVer:"v2.16.3", GitCommit:"1ee0254c86d4ed6887327dabed7aa7da29d7eb0d", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.16.3", GitCommit:"1ee0254c86d4ed6887327dabed7aa7da29d7eb0d", GitTreeState:"clean"}
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$
```

Helm v2 installation also deploys tiller Pod.
No application pods are running.
```
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ kubectl get all
NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.51.240.1   <none>        443/TCP   13m
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ kubectl get deploy,svc tiller-deploy -n kube-system
NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.extensions/tiller-deploy   1/1     1            1           81s

NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)     AGE
service/tiller-deploy   ClusterIP   10.51.240.136   <none>        44134/TCP   80s
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$
```

There is no helm chart/application release installed. 
```
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm list
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$
```

### Install a new Application release.
```
shreyans_mulkutkar@cloudshell:~/my_utilities (smulkutk-project-1)$
shreyans_mulkutkar@cloudshell:~/my_utilities (smulkutk-project-1)$ cd helmv2
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm install helm_example/
NAME:   kneeling-zebra
LAST DEPLOYED: Thu Mar 12 07:16:08 2020
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Deployment
NAME                  AGE
nginx-deploy-example  0s

==> v1/Pod(related)
NAME                                   AGE
nginx-deploy-example-78c668d7fb-ffg6x  0s
nginx-deploy-example-78c668d7fb-gr7g9  0s
nginx-deploy-example-78c668d7fb-t4pxw  0s

==> v1/Service
NAME               AGE
nginx-svc-example  0s

NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=helm_example,app.kubernetes.io/instance=kneeling-zebra" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl port-forward $POD_NAME 8080:80

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$
```

Application Pods are up and running -
```
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ kubectl get all
NAME                                        READY   STATUS    RESTARTS   AGE
pod/nginx-deploy-example-78c668d7fb-ffg6x   1/1     Running   0          39s
pod/nginx-deploy-example-78c668d7fb-gr7g9   1/1     Running   0          39s
pod/nginx-deploy-example-78c668d7fb-t4pxw   1/1     Running   0          39s

NAME                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/kubernetes          ClusterIP   10.51.240.1     <none>        443/TCP   14m
service/nginx-svc-example   ClusterIP   10.51.245.227   <none>        80/TCP    39s

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deploy-example   3/3     3            3           39s

NAME                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-deploy-example-78c668d7fb   3         3         3       39s
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$
```

Helm release can be seen in the 'helm list'
```
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm list
NAME            REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
kneeling-zebra  1               Thu Mar 12 07:16:08 2020        DEPLOYED        helm_example-0.1.0      1.0             default
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$
```

### Move Helm v2.16.3 binary name from 'helm' to 'helm2'
```
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ sudo cp /usr/local/bin/helm /usr/local/bin/helm2
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm2 list
NAME            REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
kneeling-zebra  1               Thu Mar 12 07:16:08 2020        DEPLOYED        helm_example-0.1.0      1.0             default
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$
```

## Install Helm v3 binary.
```
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ curl -L https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  6794  100  6794    0     0  56165      0 --:--:-- --:--:-- --:--:-- 56616
Helm v3.1.1 is available. Changing from version <no value>.
Downloading https://get.helm.sh/helm-v3.1.1-linux-amd64.tar.gz
Preparing to install helm into /usr/local/bin
helm installed into /usr/local/bin/helm
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm version
version.BuildInfo{Version:"v3.1.1", GitCommit:"afe70585407b420d0097d07b21c47dc511525ac8", GitTreeState:"clean", GoVersion:"go1.13.8"}
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$
```

To be safe, copy new 'helm' v3 binary as 'helmv3'
```
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ sudo cp /usr/local/bin/helm /usr/local/bin/helm3
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm version
version.BuildInfo{Version:"v3.1.1", GitCommit:"afe70585407b420d0097d07b21c47dc511525ac8", GitTreeState:"clean", GoVersion:"go1.13.8"}
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm3 version
version.BuildInfo{Version:"v3.1.1", GitCommit:"afe70585407b420d0097d07b21c47dc511525ac8", GitTreeState:"clean", GoVersion:"go1.13.8"}
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm3 list
NAME    NAMESPACE       REVISION        UPDATED STATUS  CHART   APP VERSION
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ helm2 list
NAME            REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
kneeling-zebra  1               Thu Mar 12 07:16:08 2020        DEPLOYED        helm_example-0.1.0      1.0             default
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$
```

## Install 2to3 plugin and Migrate:
### Install 'helm-2to3' plugin:
```
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2 (smulkutk-project-1)$ cd ../helmv2tov3/
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2tov3 (smulkutk-project-1)$ cat install_helm2to3_plugin.sh
helm plugin install https://github.com/helm/helm-2to3.git

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2tov3 (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2tov3 (smulkutk-project-1)$ ./install_helm2to3_plugin.sh
Downloading and installing helm-2to3 v0.4.1 ...
https://github.com/helm/helm-2to3/releases/download/v0.4.1/helm-2to3_0.4.1_linux_amd64.tar.gz
Installed plugin: 2to3
shreyans_mulkutkar@cloudshell:~/my_utilities/helmv2tov3 (smulkutk-project-1)$
```

### Migrate Helm v2 configuration using "helm 2to3 move config"
```
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm 2to3 move config --help
migrate Helm v2 configuration in-place to Helm v3

Usage:
  2to3 move config [flags]

Flags:
      --dry-run   simulate a command
  -h, --help      help for move
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm 2to3 move config --dry-run
2020/03/12 07:24:31 NOTE: This is in dry-run mode, the following actions will not be executed.
2020/03/12 07:24:31 Run without --dry-run to take the actions described below:
2020/03/12 07:24:31
2020/03/12 07:24:31 WARNING: Helm v3 configuration may be overwritten during this operation.
2020/03/12 07:24:31
[Move Config/confirm] Are you sure you want to move the v2 configuration? [y/N]: y
2020/03/12 07:24:32
Helm v2 configuration will be moved to Helm v3 configuration.
2020/03/12 07:24:32 [Helm 2] Home directory: /home/shreyans_mulkutkar/.helm
2020/03/12 07:24:32 [Helm 3] Config directory: /home/shreyans_mulkutkar/.config/helm
2020/03/12 07:24:32 [Helm 3] Data directory: /home/shreyans_mulkutkar/.local/share/helm
2020/03/12 07:24:32 [Helm 3] Cache directory: /home/shreyans_mulkutkar/.cache/helm
2020/03/12 07:24:32 [Helm 3] Create config folder "/home/shreyans_mulkutkar/.config/helm" .
2020/03/12 07:24:32 [Helm 2] repositories file "/home/shreyans_mulkutkar/.helm/repository/repositories.yaml" will copy to [Helm 3] config folder "/home/shreyans_mulkutkar/.config/helm/repositories.yaml" .
2020/03/12 07:24:32 [Helm 3] Create cache folder "/home/shreyans_mulkutkar/.cache/helm" .
2020/03/12 07:24:32 [Helm 3] Create data folder "/home/shreyans_mulkutkar/.local/share/helm" .
2020/03/12 07:24:32 [Helm 2] starters "/home/shreyans_mulkutkar/.helm/starters" will copy to [Helm 3] data folder "/home/shreyans_mulkutkar/.local/share/helm/starters" .
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$
```

Note:
- The move config command will create the Helm v3 config and data folders if they don't exist, and will override the repositories.yaml file if it does exist.
- For migration it uses default Helm v2 home and v3 config and data folders. To override those folders you need to set environment variables HELM_V2_HOME, HELM_V3_CONFIG and HELM_V3_DATA
```
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm 2to3 move config 
2020/03/12 07:24:50 WARNING: Helm v3 configuration may be overwritten during this operation.
2020/03/12 07:24:50
[Move Config/confirm] Are you sure you want to move the v2 configuration? [y/N]: y
2020/03/12 07:24:51
Helm v2 configuration will be moved to Helm v3 configuration.
2020/03/12 07:24:51 [Helm 2] Home directory: /home/shreyans_mulkutkar/.helm
2020/03/12 07:24:51 [Helm 3] Config directory: /home/shreyans_mulkutkar/.config/helm
2020/03/12 07:24:51 [Helm 3] Data directory: /home/shreyans_mulkutkar/.local/share/helm
2020/03/12 07:24:51 [Helm 3] Cache directory: /home/shreyans_mulkutkar/.cache/helm
2020/03/12 07:24:51 [Helm 3] Create config folder "/home/shreyans_mulkutkar/.config/helm" .
2020/03/12 07:24:51 [Helm 3] Config folder "/home/shreyans_mulkutkar/.config/helm" created.
2020/03/12 07:24:51 [Helm 2] repositories file "/home/shreyans_mulkutkar/.helm/repository/repositories.yaml" will copy to [Helm 3] config folder "/home/shreyans_mulkutkar/.config/helm/repositories.yaml" .
2020/03/12 07:24:51 [Helm 2] repositories file "/home/shreyans_mulkutkar/.helm/repository/repositories.yaml" copied successfully to [Helm 3] config folder "/home/shreyans_mulkutkar/.config/helm/repositories.yaml" .
2020/03/12 07:24:51 [Helm 3] Create cache folder "/home/shreyans_mulkutkar/.cache/helm" .
2020/03/12 07:24:51 [Helm 3] cache folder "/home/shreyans_mulkutkar/.cache/helm" created.
2020/03/12 07:24:51 [Helm 3] Create data folder "/home/shreyans_mulkutkar/.local/share/helm" .
2020/03/12 07:24:51 [Helm 3] data folder "/home/shreyans_mulkutkar/.local/share/helm" created.
2020/03/12 07:24:51 [Helm 2] starters "/home/shreyans_mulkutkar/.helm/starters" will copy to [Helm 3] data folder "/home/shreyans_mulkutkar/.local/share/helm/starters" .
2020/03/12 07:24:51 [Helm 2] starters "/home/shreyans_mulkutkar/.helm/starters" copied successfully to [Helm 3] data folder "/home/shreyans_mulkutkar/.local/share/helm/starters" .
2020/03/12 07:24:51 Helm v2 configuration was moved successfully to Helm v3 configuration.
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$
```

Note: Helm still points to version v2.16.3
(Remember, I had renamed my binary from helm to helm2)
```
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm2 version
Client: &version.Version{SemVer:"v2.16.3", GitCommit:"1ee0254c86d4ed6887327dabed7aa7da29d7eb0d", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.16.3", GitCommit:"1ee0254c86d4ed6887327dabed7aa7da29d7eb0d", GitTreeState:"clean"}
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm3 version
version.BuildInfo{Version:"v3.1.1", GitCommit:"afe70585407b420d0097d07b21c47dc511525ac8", GitTreeState:"clean", GoVersion:"go1.13.8"}
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm version
version.BuildInfo{Version:"v3.1.1", GitCommit:"afe70585407b420d0097d07b21c47dc511525ac8", GitTreeState:"clean", GoVersion:"go1.13.8"}
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm3 list
NAME    NAMESPACE       REVISION        UPDATED STATUS  CHART   APP VERSION
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm2 list
NAME            REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
kneeling-zebra  1               Thu Mar 12 07:16:08 2020        DEPLOYED        helm_example-0.1.0      1.0             default
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$
```

### Migrate Helm v2 releases
Use 'helm 2to3 convert __' command
```
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm 2to3 convert --help
migrate Helm v2 release in-place to Helm v3

Usage:
  2to3 convert [flags] RELEASE

Flags:
      --delete-v2-releases         v2 release versions are deleted after migration. By default, the v2 release versions are retained
      --dry-run                    simulate a command
  -h, --help                       help for convert
      --kube-context string        name of the kubeconfig context to use
      --kubeconfig string          path to the kubeconfig file
  -l, --label string               label to select Tiller resources by (default "OWNER=TILLER")
  -s, --release-storage string     v2 release storage type/object. It can be 'secrets' or 'configmaps'. This is only used with the 'tiller-out-cluster' flag (default "secrets")
      --release-versions-max int   limit the maximum number of versions converted per release. Use 0 for no limit (default 10)
  -t, --tiller-ns string           namespace of Tiller (default "kube-system")
      --tiller-out-cluster         when  Tiller is not running in the cluster e.g. Tillerless
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$
```

### Now using 'helm 2to3 convert __' to migrate above 'goodly-abalone' v2 release that was just created.
Existing v2 release:
```
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm3 list
NAME    NAMESPACE       REVISION        UPDATED STATUS  CHART   APP VERSION
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm2 list
NAME            REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
kneeling-zebra  1               Thu Mar 12 07:16:08 2020        DEPLOYED        helm_example-0.1.0      1.0             default
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$
```

Using 'dry-run' version of helm 2to3 convert to test the migration
```
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm 2to3 convert --dry-run kneeling-zebra
2020/03/12 07:27:10 NOTE: This is in dry-run mode, the following actions will not be executed.
2020/03/12 07:27:10 Run without --dry-run to take the actions described below:
2020/03/12 07:27:10
2020/03/12 07:27:10 Release "kneeling-zebra" will be converted from Helm v2 to Helm v3.
2020/03/12 07:27:10 [Helm 3] Release "kneeling-zebra" will be created.
2020/03/12 07:27:10 [Helm 3] ReleaseVersion "kneeling-zebra.v1" will be created.
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$
```

Without --dry-run, go ahead and migrate the v2 release:
```
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm 2to3 convert kneeling-zebra
2020/03/12 07:27:32 Release "kneeling-zebra" will be converted from Helm v2 to Helm v3.
2020/03/12 07:27:32 [Helm 3] Release "kneeling-zebra" will be created.
2020/03/12 07:27:32 [Helm 3] ReleaseVersion "kneeling-zebra.v1" will be created.
2020/03/12 07:27:32 [Helm 3] ReleaseVersion "kneeling-zebra.v1" created.
2020/03/12 07:27:32 [Helm 3] Release "kneeling-zebra" created.
2020/03/12 07:27:32 Release "kneeling-zebra" was converted successfully from Helm v2 to Helm v3.
2020/03/12 07:27:32 Note: The v2 release information still remains and should be removed to avoid conflicts with the migrated v3 release.
2020/03/12 07:27:32 v2 release information should only be removed using `helm 2to3` cleanup and when all releases have been migrated over.
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$
```

Note:
- Tiller deployment and service still exists.
- Now you can see the 'kneeling-zebra' release also under Helm3 list. 
```
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm version
version.BuildInfo{Version:"v3.1.1", GitCommit:"afe70585407b420d0097d07b21c47dc511525ac8", GitTreeState:"clean", GoVersion:"go1.13.8"}
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm3 version
version.BuildInfo{Version:"v3.1.1", GitCommit:"afe70585407b420d0097d07b21c47dc511525ac8", GitTreeState:"clean", GoVersion:"go1.13.8"}
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm2 version
Client: &version.Version{SemVer:"v2.16.3", GitCommit:"1ee0254c86d4ed6887327dabed7aa7da29d7eb0d", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.16.3", GitCommit:"1ee0254c86d4ed6887327dabed7aa7da29d7eb0d", GitTreeState:"clean"}
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm3 list
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
kneeling-zebra  default         1               2020-03-12 14:16:08.168493614 +0000 UTC deployed        helm_example-0.1.0      1.0
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm2 list
NAME            REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
kneeling-zebra  1               Thu Mar 12 07:16:08 2020        DEPLOYED        helm_example-0.1.0      1.0             default
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ kubectl get deploy,svc tiller-deploy -n kube-system
NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.extensions/tiller-deploy   1/1     1            1           17m

NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)     AGE
service/tiller-deploy   ClusterIP   10.51.240.136   <none>        44134/TCP   17m
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ kubectl get all
NAME                                        READY   STATUS    RESTARTS   AGE
pod/nginx-deploy-example-78c668d7fb-ffg6x   1/1     Running   0          15m
pod/nginx-deploy-example-78c668d7fb-gr7g9   1/1     Running   0          15m
pod/nginx-deploy-example-78c668d7fb-t4pxw   1/1     Running   0          15m

NAME                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/kubernetes          ClusterIP   10.51.240.1     <none>        443/TCP   29m
service/nginx-svc-example   ClusterIP   10.51.245.227   <none>        80/TCP    15m

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deploy-example   3/3     3            3           15m

NAME                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-deploy-example-78c668d7fb   3         3         3       15m
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$
```

### Clean up Helm v2 data
Clean up Helm v2 configuration, release data and Tiller deployment:
```
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm 2to3 cleanup --help
cleanup Helm v2 configuration, release data and Tiller deployment

Usage:
  2to3 cleanup [flags]

Flags:
      --config-cleanup           if set, configuration cleanup performed
      --dry-run                  simulate a command
  -h, --help                     help for cleanup
      --kube-context string      name of the kubeconfig context to use
      --kubeconfig string        path to the kubeconfig file
  -l, --label string             label to select Tiller resources by (default "OWNER=TILLER")
      --release-cleanup          if set, release data cleanup performed
  -s, --release-storage string   v2 release storage type/object. It can be 'secrets' or 'configmaps'. This is only used with the 'tiller-out-cluster' flag (default "secrets")
      --tiller-cleanup           if set, Tiller cleanup performed
  -t, --tiller-ns string         namespace of Tiller (default "kube-system")
      --tiller-out-cluster       when  Tiller is not running in the cluster e.g. Tillerless
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$
```

Start with dry-run to see everything looks okay -
```
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm 2to3 cleanup --dry-run
2020/03/12 07:32:11 NOTE: This is in dry-run mode, the following actions will not be executed.
2020/03/12 07:32:11 Run without --dry-run to take the actions described below:
2020/03/12 07:32:11
WARNING: "Helm v2 Configuration" "Release Data" "Release Data" will be removed.
This will clean up all releases managed by Helm v2. It will not be possible to restore them if you haven't made a backup of the releases.
Helm v2 may not be usable afterwards.

[Cleanup/confirm] Are you sure you want to cleanup Helm v2 data? [y/N]: y
2020/03/12 07:32:12
Helm v2 data will be cleaned up.
2020/03/12 07:32:12 [Helm 2] Releases will be deleted.
2020/03/12 07:32:12 [Helm 2] ReleaseVersion "kneeling-zebra.v1" will be deleted.
2020/03/12 07:32:12 [Helm 2] Tiller in "kube-system" namespace will be removed.
2020/03/12 07:32:12 [Helm 2] Home folder "/home/shreyans_mulkutkar/.helm" will be deleted.
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$
```

Finally, go ahead and cleanup Helm v2 data.
```
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm 2to3 cleanup
WARNING: "Helm v2 Configuration" "Release Data" "Release Data" will be removed.
This will clean up all releases managed by Helm v2. It will not be possible to restore them if you haven't made a backup of the releases.
Helm v2 may not be usable afterwards.

[Cleanup/confirm] Are you sure you want to cleanup Helm v2 data? [y/N]: y
2020/03/12 07:32:49
Helm v2 data will be cleaned up.
2020/03/12 07:32:49 [Helm 2] Releases will be deleted.
2020/03/12 07:32:49 [Helm 2] ReleaseVersion "kneeling-zebra.v1" will be deleted.
2020/03/12 07:32:49 [Helm 2] ReleaseVersion "kneeling-zebra.v1" deleted.
2020/03/12 07:32:49 [Helm 2] Releases deleted.
2020/03/12 07:32:49 [Helm 2] Tiller in "kube-system" namespace will be removed.
2020/03/12 07:32:49 [Helm 2] Tiller "deploy" in "kube-system" namespace will be removed.
2020/03/12 07:32:49 [Helm 2] Tiller "deploy" in "kube-system" namespace was removed successfully.
2020/03/12 07:32:49 [Helm 2] Tiller "service" in "kube-system" namespace will be removed.
2020/03/12 07:32:49 [Helm 2] Tiller "service" in "kube-system" namespace was removed successfully.
2020/03/12 07:32:49 [Helm 2] Tiller in "kube-system" namespace was removed.
2020/03/12 07:32:49 [Helm 2] Home folder "/home/shreyans_mulkutkar/.helm" will be deleted.
2020/03/12 07:32:49 [Helm 2] Home folder "/home/shreyans_mulkutkar/.helm" deleted.
2020/03/12 07:32:49 Helm v2 data was cleaned up successfully.
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$
```

### After the Helmv2 cleanup, the tiller Pod no longer exists. 
```
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm2 version
Client: &version.Version{SemVer:"v2.16.3", GitCommit:"1ee0254c86d4ed6887327dabed7aa7da29d7eb0d", GitTreeState:"clean"}
Error: could not find tiller
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ kubectl get deploy,svc tiller-deploy -n kube-system
Error from server (NotFound): deployments.extensions "tiller-deploy" not found
Error from server (NotFound): services "tiller-deploy" not found
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$
```

Also, you can't see any releases under 'helm2 list'
```
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm2 list
Error: could not find tiller
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$
```


Application Pods still exists.
```
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ kubectl get all
NAME                                        READY   STATUS    RESTARTS   AGE
pod/nginx-deploy-example-78c668d7fb-ffg6x   1/1     Running   0          18m
pod/nginx-deploy-example-78c668d7fb-gr7g9   1/1     Running   0          18m
pod/nginx-deploy-example-78c668d7fb-t4pxw   1/1     Running   0          18m

NAME                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/kubernetes          ClusterIP   10.51.240.1     <none>        443/TCP   32m
service/nginx-svc-example   ClusterIP   10.51.245.227   <none>        80/TCP    18m

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deploy-example   3/3     3            3           18m

NAME                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-deploy-example-78c668d7fb   3         3         3       18m
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$
```

Helm3 takes over the release. 
```
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm version
version.BuildInfo{Version:"v3.1.1", GitCommit:"afe70585407b420d0097d07b21c47dc511525ac8", GitTreeState:"clean", GoVersion:"go1.13.8"}
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm3 version
version.BuildInfo{Version:"v3.1.1", GitCommit:"afe70585407b420d0097d07b21c47dc511525ac8", GitTreeState:"clean", GoVersion:"go1.13.8"}
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ helm3 list
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
kneeling-zebra  default         1               2020-03-12 14:16:08.168493614 +0000 UTC deployed        helm_example-0.1.0      1.0
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$

shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$ kubectl get all
NAME                                        READY   STATUS    RESTARTS   AGE
pod/nginx-deploy-example-78c668d7fb-ffg6x   1/1     Running   0          23m
pod/nginx-deploy-example-78c668d7fb-gr7g9   1/1     Running   0          23m
pod/nginx-deploy-example-78c668d7fb-t4pxw   1/1     Running   0          23m

NAME                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/kubernetes          ClusterIP   10.51.240.1     <none>        443/TCP   37m
service/nginx-svc-example   ClusterIP   10.51.245.227   <none>        80/TCP    23m

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deploy-example   3/3     3            3           23m

NAME                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-deploy-example-78c668d7fb   3         3         3       23m
shreyans_mulkutkar@cloudshell:~/.helm (smulkutk-project-1)$
```

## References:
- https://helm.sh/docs/topics/v2_v3_migration/
- https://github.com/helm/helm-2to3
- https://helm.sh/blog/migrate-from-helm-v2-to-helm-v3/