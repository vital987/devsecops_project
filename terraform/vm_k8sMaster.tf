resource "azurerm_network_security_group" "nsg_k8sMaster" {
  name                = "nsg_k8sMaster"
  resource_group_name = azurerm_resource_group.pipeline.name
  location            = azurerm_resource_group.pipeline.location


  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "KubernetesAPIserver"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "etcdServerClientAPI"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "2379-2380"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "KubeletAPI"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "10250"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "kube-scheduler"
    priority                   = 500
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "10259"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "kube-controller-manager"
    priority                   = 600
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "10257"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_network_interface_security_group_association" "anisga_k8sMaster" {
  network_interface_id      = azurerm_network_interface.nic_k8sMaster.id
  network_security_group_id = azurerm_network_security_group.nsg_k8sMaster.id
}


resource "azurerm_public_ip" "ip_k8sMaster" {
  name                = "ip_k8sMaster"
  resource_group_name = azurerm_resource_group.pipeline.name
  location            = azurerm_resource_group.pipeline.location
  allocation_method   = "Dynamic"
}


resource "azurerm_network_interface" "nic_k8sMaster" {
  name                = "nic_k8sMaster"
  resource_group_name = azurerm_resource_group.pipeline.name
  location            = azurerm_resource_group.pipeline.location


  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.s3.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip_k8sMaster.id
  }
}


resource "azurerm_linux_virtual_machine" "vm_k8sMaster" {
  name                  = "vm-k8sMaster"
  resource_group_name   = azurerm_resource_group.pipeline.name
  location              = azurerm_resource_group.pipeline.location
  size                  = "Standard_B1s"
  admin_username        = var.user
  network_interface_ids = [azurerm_network_interface.nic_k8sMaster.id]
  depends_on = [
    azurerm_kubernetes_cluster.cluster_k8sWorker
  ]

  admin_ssh_key {
    username   = var.user
    public_key = tls_private_key.key_k8sMaster.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = "64"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  connection {
    type        = "ssh"
    user        = var.user
    private_key = tls_private_key.key_k8sMaster.private_key_openssh
    host        = self.public_ip_address
  }

  provisioner "file" {
    content     = tls_private_key.key_k8sMaster.public_key_openssh
    destination = "/home/${var.user}/.ssh/id_rsa.pub"
  }

  provisioner "file" {
    content     = tls_private_key.key_k8sMaster.private_key_openssh
    destination = "/home/${var.user}/.ssh/id_rsa"
  }

  provisioner "file" {
    content     = tls_private_key.key_ansible.public_key_openssh
    destination = "/home/${var.user}/.ssh/authorized_keys2"
  }

  provisioner "remote-exec" {
    script = "../configFiles/k8sMaster/config/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 0600 /home/${var.user}/.ssh/id_rsa",
      "az login --identity",
      "az aks get-credentials --admin --resource-group ${var.rgname} --name ${azurerm_kubernetes_cluster.cluster_k8sWorker.name}",
      "kubectl create namespace ingress-nginx",
      <<EOF
helm install ingress-nginx ingress-nginx/ingress-nginx \
--namespace ingress-nginx \
--set controller.replicaCount=2 \
--set controller.nodeSelector."kubernetes\.io/os"=linux \
--set defaultBackend.nodeSelector."kubernetes\.io/os"=linux \
--set controller.service.externalTrafficPolicy=Local \
--set controller.service.loadBalancerIP="${azurerm_public_ip.ip_ingress.ip_address}"
EOF
    ]
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.k8sClusterAccess.id]
  }
}


resource "tls_private_key" "key_k8sMaster" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}


resource "local_file" "local_key_k8sMaster" {
  filename        = "../sshKeys/k8sMaster.key"
  content         = tls_private_key.key_k8sMaster.private_key_openssh
  file_permission = "0600"
}


resource "azurerm_role_assignment" "accessClusterCreds" {
  scope                = azurerm_resource_group.pipeline.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = azurerm_user_assigned_identity.k8sClusterAccess.principal_id
}


resource "azurerm_role_assignment" "clusterAdmin" {
  scope                = azurerm_resource_group.pipeline.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = azurerm_user_assigned_identity.k8sClusterAccess.principal_id
}


resource "azurerm_user_assigned_identity" "k8sClusterAccess" {
  name                = "k8sClusterAccess"
  location            = azurerm_resource_group.pipeline.location
  resource_group_name = azurerm_resource_group.pipeline.name
}