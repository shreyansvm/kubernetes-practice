# Practice examples on:
- NodeSelector
- Applying taints to a node:
  - Example: kubectl taint nodes gke-k8s-cluster-default-pool-8cfb3581-zgf7 env=dev:NoSchedule
- Scheduling a Pod on tainted node using 'toleration'
```
      tolerations:
      # Using this, we are telling the K8s control plan that this Pod has toleration for the node with taint 'env=dev:NoSchedule'
      - key: "env"
        operator: "Equal"
        value: "dev"
        effect: "NoSchedule"
```
