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

# Manage Containers

# Manage Images

# Info and Stats

