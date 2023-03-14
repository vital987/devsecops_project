resource "azurerm_network_security_group" "nsg_jenkins" {
  name                = "nsg_jenkins"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  security_rule {
    name                       = "Allow-Jenkins"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
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

resource "azurerm_network_interface_security_group_association" "anisga_jenkins" {
  network_interface_id      = azurerm_network_interface.nic_jenkins.id
  network_security_group_id = azurerm_network_security_group.nsg_jenkins.id
}

resource "azurerm_public_ip" "ip_jenkins" {
  name                = "ip_jenkins"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic_jenkins" {
  name                = "nic_jenkins"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.s0.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.4"
    public_ip_address_id          = azurerm_public_ip.ip_jenkins.id
  }
}

resource "azurerm_linux_virtual_machine" "vm_jenkins" {
  name                  = "vm-jenkins"
  resource_group_name   = azurerm_resource_group.rg1.name
  location              = azurerm_resource_group.rg1.location
  size                  = "Standard_B1ms"
  admin_username        = var.user
  network_interface_ids = [azurerm_network_interface.nic_jenkins.id]
  custom_data           = filebase64("../customData/jenkins.sh")
  admin_ssh_key {
    username   = var.user
    public_key = tls_private_key.key_jenkins.public_key_openssh
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
    private_key = tls_private_key.key_jenkins.private_key_openssh
    host        = self.public_ip_address
  }
  provisioner "file" {
    content     = tls_private_key.key_jenkins.public_key_openssh
    destination = "/home/${var.user}/.ssh/id_rsa.pub"
  }
  provisioner "file" {
    content     = tls_private_key.key_jenkins.private_key_openssh
    destination = "/home/${var.user}/.ssh/id_rsa"
  }
  provisioner "file" {
    content     = tls_private_key.key_ansible.private_key_openssh
    destination = "/home/${var.user}/.ssh/ansible.key"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod 0600 /home/${var.user}/.ssh/id_rsa",
      "chmod 0600 /home/${var.user}/.ssh/ansible.key",
      "ssh-keygen -p -f /home/${var.user}/.ssh/ansible.key -m pem -N ''",
    ]
  }
}
resource "tls_private_key" "key_jenkins" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}
resource "local_file" "local_key_jenkins" {
  filename        = "../sshKeys/jenkins.key"
  content         = tls_private_key.key_jenkins.private_key_openssh
  file_permission = "0600"
}
