# Liveness, Readiness and Startup Probes
- kubelet uses **liveness probes** to know when to restart a Container. It is like health check
- kubelet uses **readiness probes** to know when a Container is ready to start accepting traffic
- kubelet uses **startup probes** to know when a Container application has started

For more details, refer: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
