* create directories User jenkins within docker image has uid 999, so:
```
sudo mkdir -p /opt/jenkins/gitcache
sudo mkdir -p /opt/jenkins/ccache
sudo mkdir -p /opt/jenkins/workspace
sudo chown -R 999 /opt/jenkins/gitcache
sudo chown -R 999 /opt/jenkins/ccache
sudo chown -R 999 /opt/jenkins/workspace
```

* Create Docker Container
```
docker build -t riotci-jenkins .
docker create -v "/etc/localtime:/etc/localtime:ro" -p 2222:22 --name riotci-jenkins -v /opt/jenkins/ccache:/opt/jenkins/ccache -v /opt/jenkins/gitcache:/opt/jenkins/gitcache --tmpfs /tmp --restart "always" -w /opt/jenkins riotci-jenkins
```

* Create Systemd Service
```
sudo cp docker-jenkinsslave.service /etc/systemd/system/.
sudo systemctl daemon-reload
sudo systemctl enable docker-riotci-jenkins.service
sudo systemctl start docker-riotci-jenkins.service
```

* connect to docker instance

```
sudo docker exec -i -u 999 -t riotci-jenkins /bin/bash
```
