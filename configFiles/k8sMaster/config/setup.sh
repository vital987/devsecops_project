#!/bin/bash

sudo su -c '
echo "Installing base packages..."
apt-get update >/dev/null
apt-get install -y gnupg ca-certificates apt-transport-https curl python3 python3-pip >/dev/null
echo "Installing Helm..."
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg >/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/\
stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list >/dev/null
apt-get update >/dev/null
apt-get install -y helm >/dev/null
echo "Installing Kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/bin/kubectl
rm -f kubectl
curl -sL https://aka.ms/InstallAzureCLIDeb | bash >/dev/null
'
# Ingress Setup
echo "Installing Kubernetes Python package..."
pip3 install kubernetes >/dev/null
echo "Installing Ingress..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx >/dev/null
helm repo add stable https://charts.helm.sh/stable >/dev/null
helm repo update >/dev/null
