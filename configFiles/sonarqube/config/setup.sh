#!/bin/bash

sudo su -c '
echo "Updating apt lists..."
apt-get update >/dev/null
echo "Installing basic packages..."
apt-get install --no-install-recommends -y ca-certificates gnupg lsb-release curl >/dev/null
echo "Adding Docker repository..."
mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg |
  gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null
echo "Updating apt lists..."
apt-get update >/dev/null
echo "Installing Docker & Docker-compose..."
apt-get install -y docker-ce docker-ce-cli containerd.io \
  docker-compose docker-compose-plugin >/dev/null
echo "Granting permissions..."
usermod -aG docker $(id -nu 1000) || :
sysctl -w vm.max_map_count=524288
sysctl -w fs.file-max=131072
ulimit -n 131072
ulimit -u 8192
'