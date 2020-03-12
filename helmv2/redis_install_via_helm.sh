# install Redis into Kubernetes Cluster with some production values recommended by the Redis Chart maintainers
helm install stable/redis \
    --values values/values-production.yaml \
    --name redis-system