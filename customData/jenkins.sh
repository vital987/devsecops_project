#!/bin/bash

apt-get update
apt-get install --no-install-recommends -y ca-certificates gnupg git wget maven \
    curl jq apt-transport-https unzip openjdk-17-jdk

URL=$(curl -s https://api.github.com/repos/jenkinsci/jenkins/releases | jq -r \
    '.[0].assets[].browser_download_url' | grep -E *.deb$)
wget $URL -P /tmp
apt-get install -y /tmp/$(basename $URL)

URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
wget $URL -P /tmp
apt-get install -y /tmp/$(basename $URL)

URL=https://chromedriver.storage.googleapis.com/$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE)/chromedriver_linux64.zip
wget $URL -P /tmp
unzip /tmp/chromedriver_linux64.zip -d /usr/bin

mv /home/$(id -nu 1000)/.ssh/ansible.key /var/lib/jenkins
chown jenkins:jenkins /var/lib/jenkins/ansible.key

rm -rf /tmp/*

systemctl enable jenkins
service jenkins start
