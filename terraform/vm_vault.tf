resource "azurerm_network_security_group" "nsg_vault" {
  name                = "nsg_vault"
  resource_group_name = azurerm_resource_group.pipeline.name
  location            = azurerm_resource_group.pipeline.location

  security_rule {
    name                       = "Raft-Replication-RequestForwarding"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8201"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Vault-API"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8200"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "anisga_vault" {
  network_interface_id      = azurerm_network_interface.nic_vault.id
  network_security_group_id = azurerm_network_security_group.nsg_vault.id
}

resource "azurerm_network_interface" "nic_vault" {
  name                = "nic_vault"
  resource_group_name = azurerm_resource_group.pipeline.name
  location            = azurerm_resource_group.pipeline.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.s4.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip_vault.id
  }
}

resource "tls_private_key" "key_vault" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "azurerm_public_ip" "ip_vault" {
  name                = "ip_vault"
  resource_group_name = azurerm_resource_group.pipeline.name
  location            = azurerm_resource_group.pipeline.location
  allocation_method   = "Dynamic"
}

resource "azurerm_linux_virtual_machine" "vm_vault" {
  name                  = "vm-vault"
  resource_group_name   = azurerm_resource_group.pipeline.name
  location              = azurerm_resource_group.pipeline.location
  size                  = "Standard_B1s"
  admin_username        = var.user
  network_interface_ids = [azurerm_network_interface.nic_vault.id]

  admin_ssh_key {
    username   = var.user
    public_key = tls_private_key.key_vault.public_key_openssh
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
    private_key = tls_private_key.key_vault.private_key_openssh
    host        = self.public_ip_address
  }

  provisioner "file" {
    content     = tls_private_key.key_vault.public_key_openssh
    destination = "/home/${var.user}/.ssh/id_rsa.pub"
  }

  provisioner "file" {
    content     = tls_private_key.key_vault.private_key_openssh
    destination = "/home/${var.user}/.ssh/id_rsa"
  }

  provisioner "file" {
    source      = "../configFiles/vault/assets/config.hcl"
    destination = "/home/${var.user}/vault.hcl"
  }

  provisioner "remote-exec" {
    script = "../configFiles/vault/config/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 0600 /home/${var.user}/.ssh/id_rsa",
      "sudo mv /home/${var.user}/vault.hcl /etc/vault.d/vault.hcl",
      "sudo systemctl enable vault",
      "sudo service vault start"
    ]
  }
}


resource "local_file" "local_key_vault" {
  filename        = "../sshKeys/vault.key"
  content         = tls_private_key.key_vault.private_key_openssh
  file_permission = "0600"
}
