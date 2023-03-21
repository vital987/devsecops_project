resource "azurerm_network_security_group" "nsg_ansible" {
  name                = "nsg_ansible"
  resource_group_name = azurerm_resource_group.pipeline.name
  location            = azurerm_resource_group.pipeline.location

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_network_interface_security_group_association" "anisga_ansible" {
  network_interface_id      = azurerm_network_interface.nic_ansible.id
  network_security_group_id = azurerm_network_security_group.nsg_ansible.id
}


resource "azurerm_public_ip" "ip_ansible" {
  name                = "ip_ansible"
  resource_group_name = azurerm_resource_group.pipeline.name
  location            = azurerm_resource_group.pipeline.location
  allocation_method   = "Dynamic"
}


resource "azurerm_network_interface" "nic_ansible" {
  name                = "nic_ansible"
  resource_group_name = azurerm_resource_group.pipeline.name
  location            = azurerm_resource_group.pipeline.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.s2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip_ansible.id
  }
}

resource "azurerm_linux_virtual_machine" "vm_ansible" {
  name                  = "vm-ansible"
  resource_group_name   = azurerm_resource_group.pipeline.name
  location              = azurerm_resource_group.pipeline.location
  size                  = "Standard_B1s"
  admin_username        = var.user
  network_interface_ids = [azurerm_network_interface.nic_ansible.id]
  custom_data           = filebase64("../customData/ansible.sh")
  depends_on = [
    azurerm_linux_virtual_machine.vm_k8sMaster
  ]

  admin_ssh_key {
    username   = var.user
    public_key = tls_private_key.key_ansible.public_key_openssh
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
    private_key = tls_private_key.key_ansible.private_key_openssh
    host        = self.public_ip_address
  }

  provisioner "file" {
    content     = tls_private_key.key_ansible.public_key_openssh
    destination = "/home/${var.user}/.ssh/id_rsa.pub"
  }

  provisioner "file" {
    content     = tls_private_key.key_ansible.private_key_openssh
    destination = "/home/${var.user}/.ssh/id_rsa"
  }
  # provisioner "file" {
  #   content     = tls_private_key.key_jenkins.public_key_openssh
  #   destination = "/home/${var.user}/.ssh/authorized_keys2"
  # }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir /etc/ansible || :",
      "sudo chown -R ${var.user}:${var.user} /etc/ansible"
    ]
  }

  provisioner "file" {
    source      = "../configFiles/ansible/config/"
    destination = "/etc/ansible"
  }

  provisioner "file" {
    source      = "../configFiles/ansible/assets/"
    destination = "/home/${var.user}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 0600 /home/${var.user}/.ssh/id_rsa",
      "echo export ANSIBLE_DISABLE_HOST_KEY_CHECKING=true >> /home/${var.user}/.bashrc",
      "echo ${azurerm_linux_virtual_machine.vm_k8sMaster.public_ip_address} | sudo tee -a /etc/ansible/hosts",
    ]
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.storageBlobAccess.id]
  }
}


resource "tls_private_key" "key_ansible" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}


resource "local_file" "local_key_ansible" {
  filename        = "../sshKeys/ansible.key"
  content         = tls_private_key.key_ansible.private_key_openssh
  file_permission = "0600"
}


resource "azurerm_role_assignment" "storageContributor" {
  scope                = azurerm_resource_group.pipeline.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.storageBlobAccess.principal_id
}


resource "azurerm_user_assigned_identity" "storageBlobAccess" {
  name                = "storageBlobAccess"
  location            = azurerm_resource_group.pipeline.location
  resource_group_name = azurerm_resource_group.pipeline.name
}
