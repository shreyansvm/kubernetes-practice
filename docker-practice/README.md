# Install docker on any cloud instance (GCP, AWS,..)
```
sudo apt-get update
sudo apt install docker.io
sudo usermod -aG docker ubuntu
docker version
```

# Run Containers
## Run a new container from image
```
docker run hello-world
docker run ubuntu --name myubuntu

# login to the container
ubuntu@ip-172-31-25-102:~$ docker run --name myubuntu -it ubuntu
root@90e5c0fdb3a5:/# ls
bin  boot  dev  etc  home  lib  lib32  lib64  libx32  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
root@90e5c0fdb3a5:/# 
```

## Publish or expose port using (-p, --expose) options
```
#   Syntax:-- hostport:container-port
ubuntu@ip-172-31-25-102:~$ docker run -p 8080:80 nginx
Unable to find image 'nginx:latest' locally
latest: Pulling from library/nginx
afb6ec6fdc1c: Pull complete 
b90c53a0b692: Pull complete 
11fa52a0fdc0: Pull complete 
Digest: sha256:6fff55753e3b34e36e24e37039ee9eae1fe38a6420d8ae16ef37c92d1eb26699
Status: Downloaded newer image for nginx:latest

(base) shreyanss-mbp:~ myfolder$ curl http://localhost:80
<html><body><h1>It works!</h1></body></html>
(base) shreyanss-mbp:~ myfolder$
```

# Manage Containers

# Manage Images

# Info and Stats

