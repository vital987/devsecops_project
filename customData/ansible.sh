#!/bin/bash

apt-get update
apt-get install --no-install-recommends -y ca-certificates gnupg jq \
    lsb-release git curl ansible python3 python3-pip

mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg |
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin
usermod -aG docker $(id -nu 1000) || :

echo "PubkeyAcceptedKeyTypes +ssh-rsa" >>/etc/ssh/sshd_config
service ssh restart

runuser -l $(id -nu 1000) -c 'pip3 install docker && ansible-galaxy collection install kubernetes.core'

URL="https://github.com/aquasecurity/trivy/releases/download/v0.38.3/trivy_0.38.3_Linux-64bit.deb"
wget $URL -P /tmp
apt-get install -y /tmp/$(basename $URL)

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
