#!/bin/bash

sudo sh -c '
echo "Updating apt sources..."
apt-get update >/dev/null
echo "Installing base packages..."
apt-get install --no-install-recommends -y ca-certificates gnupg git wget maven \
    curl jq apt-transport-https unzip fontconfig openjdk-17-jdk >/dev/null

echo "Installing Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key > /usr/share/keyrings/jenkins-keyring.asc
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian binary/ > /etc/apt/sources.list.d/jenkins.list
apt-get update >/dev/null
apt-get install -y jenkins >/dev/null

echo "Installing Google Chrome..."
URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
wget $URL -q -P /tmp
apt-get install -y /tmp/$(basename $URL) >/dev/null

echo "Installing Chromedriver..."
URL="https://chromedriver.storage.googleapis.com/$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE)/chromedriver_linux64.zip"
wget $URL -q -P /tmp
unzip /tmp/chromedriver_linux64.zip -d /usr/bin >/dev/null

mv /home/$(id -nu 1000)/.ssh/ansible.key /var/lib/jenkins
chown jenkins:jenkins /var/lib/jenkins/ansible.key

rm -rf /tmp/*

systemctl enable jenkins
service jenkins start
'

sleep 15
echo "Installing Jenkins CLI..."
echo '
export JENKINS_HOME="/var/lib/jenkins"
export JENKINS_URL="http://localhost:8080"
export JENKINS_AUTH="admin:$(sudo cat $JENKINS_HOME/secrets/initialAdminPassword)"
export JENKINS_AUTH_URL="http://$JENKINS_AUTH@localhost:8080"
export JENKINS_PLUGINS="build-timeout timestamper workflow-aggregator github-branch-source pipeline-github-lib pipeline-stage-view git matrix-auth ldap publish-over-ssh slack hashicorp-vault-plugin sonar dark-theme"
' | sudo tee /etc/environment >/dev/null
source /etc/environment
sudo sh -c '
URL="$JENKINS_AUTH_URL/jnlpJars/jenkins-cli.jar"
wget $URL -q -O $JENKINS_HOME/jcli.jar
chown -R jenkins:jenkins $JENKINS_HOME/jcli.jar
'
echo "Installing Jenkins plugins..."
java -jar $JENKINS_HOME/jcli.jar -s $JENKINS_URL -auth $JENKINS_AUTH install-plugin $JENKINS_PLUGINS
java -jar $JENKINS_HOME/jcli.jar -s $JENKINS_URL -auth $JENKINS_AUTH restart
