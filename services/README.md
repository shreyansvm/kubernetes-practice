# Notes on K8s Services
- Pod IP addresses keep changing all the time.
- Containers exposes ports in the Pod spec.
- How does the client know at what IP:port the pod can be accessed?
This is where Services object come in. 

Services = logical set of backend pods + stable front-end

- Services use label selectors to map to backend pods.
  - Note: It is possible to have Services without selector.
    - use case: when your backend is not a pod. Example
      - external database cluster
      - service in another cluster
      - migrating from on-prem, some backends are not K8s. 
    - In this case, no endpoint object will be created to maintain a list of backend pods.
      - we need to manually map the service to specific backend IP+port.
    - ExternalName service could also be used to point the backend which is outside of the cluster. 

Endpoint object:
- Dynamic list of pods that are selected by a Service.
- Each service object has an associated endpoint object.
- K8s evaluates service label selector Vs all pods in the cluster.
- As new Pods get added or deleted, this dynamic list (Endpoint object) gets updated.

Kube-Proxy
- it is an entry point for external / non-K8s entities. 
- takes incoming call from external clients, resolves it and passes it to backend ClusterIP services (and eventually Pods)

Services can have Multiple Ports. 

## Types of Services objects

- ClusterIP
  - Static lifetime IP of service
  - only accessible within cluster
  - ClusterIP addresses is independent of backend pods
  - Default service type

- NodePort
  - Services are exposed on each node on a static port. 
  - External client can access the service (backend pods) via Node IP+ NodePort
  - Request will be relayed to ClusterIP + NodePort.
  - All this is carried out by kube-proxy agent on each node. Any external requests received on NodeIP+Nodeport are resolved and passed on to the corresponding service listening on ClusterIP and NodePort. 

- LoadBalancer
  - a K8s service is exposed externally to a cloud Load Balancer (e.g. provided by GCP, AWS, etc..)
  - This will automatically create a NodePort and ClusterIP services under the hood.
  - External LB -> NodePort service -> ClusterIP service -> backend Pods

- ExternalName
  - Map a service to external service i.e. residing outside the cluster.

### Service Discovery
- Pods make use of 'Service Discovery' to access some service. 
- two methods:
  - DNS lookup: Preferred
  - Enviornment Variables

DNS Service Discovery
- This is an add-on. 
- a DNS service (in the background) listens on creation of new services 
- Pods within same namespace can access the service by a simple DNS name lookup of 'service-name'
- Pods in other namespaces can access s service by DNS lookup 'namespace-name'.'service-name'
- These DNS lookup will results in the Service's ClusterIP.

'DNS SRV' query can be used to find all ports associated with the Service


