# Security Considerations for K8s-based microservices infrastructure 

## When using Docker

### Use Certified Docker Image
You can set the ‘DOCKER_CONTENT_TRUST=1’ in the environment variables. This ensures image we are pulling comes from an authorized source. Otherwise, we are leaving our systems open to man-in-the-middle (MITM) attacks.

```
export DOCKER_CONTENT_TRUST=1
```

### Check for Image Vulnerabilities
Tools like 'Snyk' can be used to continuously scan and monitor the vulnerabilities in your used Docker images. 
Example -
Let’s scan an Alpine image for vulnerabilities using the command below:
```
snyk test --docker alpine
```
Other synk commands -
```
snyk test --docker sebp/elk |tail -7
snyk monitor --docker  sebp/elk
```
Check [other tools](https://techbeacon.com/app-dev-testing/13-tools-checking-security-risk-open-source-dependencies) for checking security risks in open-source softwares -


### Protect Sensitive Data Using Docker Secrets
Docker Secrets help in protecting sensitive data in applications that are hosted and running inside a number of Docker containers in your infrastructure.
With the help of Docker secrets, you can manage sensitive data at runtime, when a Docker container needs the data but you don’t want to store it in a layer of your Docker image.

Note: Currently, Docker secrets is only applicable for Docker swarms, not for individual containers.

In order to start using Docker secrets, you need to have a Docker swarm already running. After that, add a secret to your Docker swarm, then create a service and give access to the created secret.
The secrets are mounted onto the container at the location /run/secrets.

Example -
Using following commands, a Redis service gets created, and access is given to the secret.
```
echo "My Secret Password" | docker secret create my_pass -
docker service  create --name redis --secret my_pass redis:alpine
docker container exec $(docker ps --filter name=redis -q) cat /run/secrets/my_pass
```

### Utilize Docker’s Container Restart Policy
If you think your machine goes down when a Docker daemon is running, enable the Docker service to start automatically after the machine restarts. This doesn’t mean that your previously running Docker containers will also start if your Docker daemon is up and running.

In order to start the containers automatically, use the Docker restart policy. This policy is responsible for determining what to do with a container after its exit. The default policy assigned to each container is “no,” which means that there is no action to take if a container exits.

Example -
```
# Always restart the container if it stops. If it is manually stopped, it is restarted only when Docker daemon restarts or the container itself is manually restarted. (See the second bullet listed in restart policy details)
docker run -it -d --restart always redis

# Restart the container if it exits due to an error, which manifests as a non-zero exit code.
# 'update' command can be used to change/update the restart-policy -
docker update --restart on-failure redis

#  Similar to always, except that when the container is stopped (manually or otherwise), it is not restarted even after Docker daemon restarts.
docker run -dit --restart unless-stopped redis

# Default: '--restart no' i.e. Do not automatically restart the container
```

## Acknowledgments
* https://medium.com/@IODCloudTech/5-tips-for-securing-your-docker-based-infrastructure-91e6a1bbc20c
