#!/bin/bash

# wrapper to correct owner of subdirs
JENKINS_HOME=/opt/jenkins
JENKINS_USER="jenkins"
chown -R ${JENKINS_USER}:${JENKINS_USER} ${JENKINS_HOME}
chmod -R 755 ${JENKINS_HOME}

# pass through original command
$@
