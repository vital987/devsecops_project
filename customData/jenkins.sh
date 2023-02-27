#!/bin/bash
apt-get update
apt-get install --no-install-recommends -y ca-certificates gnupg git wget maven \
    curl apt-transport-https default-jdk
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | tee \
/usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
apt-get update
apt-get install --no-install-recommends -y jenkins
systemctl enable jenkins
service jenkins start
mv /home/$(id -nu 1000)/.ssh/ansible.key /var/lib/jenkins
chown jenkins:jenkins /var/lib/jenkins/ansible.key
