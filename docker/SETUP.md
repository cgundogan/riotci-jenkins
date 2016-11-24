## Create directories  

User jenkins within the RIOT-CI docker image has UID 999, so create directories
as folllows that will be mounted into docker:

```
sudo mkdir -p /opt/jenkins/gitcache
sudo mkdir -p /opt/jenkins/ccache
sudo mkdir -p /opt/jenkins/workspace
sudo chown -R 999 /opt/jenkins/gitcache
sudo chown -R 999 /opt/jenkins/ccache
sudo chown -R 999 /opt/jenkins/workspace
```

## Create a Docker Container

First we need to create a docker container for RIOT-CI which suits Jenkins:
```
docker build -t riotci-jenkins .
docker create -v "/etc/localtime:/etc/localtime:ro" -p 2222:22 --name riotci-jenkins \
    -v /opt/jenkins/ccache:/opt/jenkins/ccache \
    -v /opt/jenkins/gitcache:/opt/jenkins/gitcache \
    -v /opt/jenkins/workspace:/opt/jenkins/workspace \
    --tmpfs /tmp --restart "always" -w /opt/jenkins riotci-jenkins
```

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
sudo cp docker-jenkinsslave.service /etc/systemd/system/.
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
