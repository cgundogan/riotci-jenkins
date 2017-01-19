## Create a Docker Container

First we need to create a docker container for RIOT-CI which suits Jenkins:
```
cd </path/to/repo>/docker
docker build -t riotci-jenkins .
docker create -v "/etc/localtime:/etc/localtime:ro" -p 2222:22 --name riotci-jenkins \
    --tmpfs /opt/jenkins/ccache:rw,size=10G,mode=1777 \
    --tmpfs /opt/jenkins/gitcache:rw,size=1G,mode=1777 \
    --tmpfs /opt/jenkins/workspace:rw,exec,size=4G,mode=1777 \
    --tmpfs /tmp:rw,size=16G,mode=1777 \
    --restart "always" -w /opt/jenkins riotci-jenkins
```

The size of the `tmpfs` partition should be adapted to the hardware resources of
the Jenkins slave node. Consider the following values:

- `/opt/jenkins/workspace` = (#cpu-cores / 2)G
- `/opt/jenkins/gitcache` = 1G
- `/opt/jenkins/ccache` = >10G
- `/tmp` = amount of RAM

The workspace depends on the number of build lanes, we typically set it to half
the number of cores (incl. HyperThreading for Intel CPUs), per build lane 1G
should be sufficient. The ccache size is critical, at least 10G should be
available, but the more the better.
The gitcache is not very large at the moment (< 100M), hence, 1G is enough.
Size of the tmp directory can be as large as the whole RAM installed.
Remember: tmpfs is lazy allocated, which means that only as much memory is used
as required. But it also uses swap if RAM is exceeded, so the sum of sizes for
all directories can be higher than the amount of RAM installed in your system.

_NOTE_: the parameter `-p 2222:22` forwards port `2222` of the docker host
machine to port `22` (SSH) of the RIOT-CI docker container.
If you have a firewall running on the docker host or the host is behind an
external NAT or firewall, you have to make port `2222` public, i.e., reachable
by the Jenkins master.

## Autostart with Systemd

The provided systemd service file makes it easy to start and stop the RIOT-CI
docker container. If you don't want to autostart the service on boot, ignore the
line with the `enable` command.

```
sudo cp docker-riotci-jenkins.service /etc/systemd/system/.
sudo systemctl daemon-reload
sudo systemctl enable docker-riotci-jenkins.service
sudo systemctl start docker-riotci-jenkins.service
```

## Connect to docker instance

The created docker container just runs a SSH server for Jenkins, however you
can still login into the running container by calling:

```
sudo docker exec -i -u 999 -t riotci-jenkins /bin/bash
```
