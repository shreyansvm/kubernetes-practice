# Init Containers
A Pod can have multiple containers running apps within it, but it can also have one or more init containers, which are run before the app containers are started.

Init containers are exactly like regular containers, except:
- Init containers always run to completion.
- Each init container must complete successfully before the next one starts.
If a Pod’s init container fails, Kubernetes repeatedly restarts the Pod until the init container succeeds


For more details, visit: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
