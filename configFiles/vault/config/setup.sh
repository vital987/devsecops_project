#/bin/bash

sudo su -c '
apt-get update
apt-get install --no-install-recommends -y ca-certificates apt-tansport-https gnupg lsb-release curl
wget -O- https://apt.releases.hashicorp.com/gpg | gpg \
    --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee \
    /etc/apt/sources.list.d/hashicorp.list
apt-get update
apt-get install --no-install-recommends -y vault
'
