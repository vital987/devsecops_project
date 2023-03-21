resource "azurerm_network_security_group" "nsg_sonarqube" {
  name                = "nsg_sonarqube"
  resource_group_name = azurerm_resource_group.pipeline.name
  location            = azurerm_resource_group.pipeline.location

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9000"
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


resource "azurerm_network_interface_security_group_association" "anisga_sonarqube" {
  network_interface_id      = azurerm_network_interface.nic_sonarqube.id
  network_security_group_id = azurerm_network_security_group.nsg_sonarqube.id
}


resource "azurerm_public_ip" "ip_sonarqube" {
  name                = "ip_sonarqube"
  resource_group_name = azurerm_resource_group.pipeline.name
  location            = azurerm_resource_group.pipeline.location
  allocation_method   = "Dynamic"
}


resource "azurerm_network_interface" "nic_sonarqube" {
  name                = "nic_sonarqube"
  resource_group_name = azurerm_resource_group.pipeline.name
  location            = azurerm_resource_group.pipeline.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.s1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip_sonarqube.id
  }
}

resource "azurerm_linux_virtual_machine" "vm_sonarqube" {
  name                  = "vm-sonarqube"
  resource_group_name   = azurerm_resource_group.pipeline.name
  location              = azurerm_resource_group.pipeline.location
  size                  = "Standard_B2s"
  admin_username        = var.user
  network_interface_ids = [azurerm_network_interface.nic_sonarqube.id]
  depends_on = [
    azurerm_private_endpoint.db_pe
  ]

  admin_ssh_key {
    username   = var.user
    public_key = tls_private_key.key_sonarqube.public_key_openssh
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
    private_key = tls_private_key.key_sonarqube.private_key_openssh
    host        = self.public_ip_address
  }

  provisioner "file" {
    content     = tls_private_key.key_sonarqube.public_key_openssh
    destination = "/home/${var.user}/.ssh/id_rsa.pub"
  }

  provisioner "file" {
    content     = tls_private_key.key_sonarqube.private_key_openssh
    destination = "/home/${var.user}/.ssh/id_rsa"
  }

  provisioner "file" {
    source      = "../configFiles/sonarqube/assets/"
    destination = "/home/${var.user}"
  }

  provisioner "remote-exec" {
    script = "../configFiles/sonarqube/config/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 0600 /home/${var.user}/.ssh/id_rsa",
      <<EOT
echo '
DB_IP=${data.azurerm_private_endpoint_connection.db_pec.private_service_connection.0.private_ip_address}
DB_NAME=${azurerm_postgresql_server.db1.name}
DB_USER=${azurerm_postgresql_server.db1.administrator_login}
DB_PASS=${azurerm_postgresql_server.db1.administrator_login_password}
' | sudo tee -a /etc/environment > /dev/null
EOT
    , "export $(cat /etc/environment) && docker-compose -f /home/${var.user}/docker-compose.yml up -d"]
  }
}


resource "tls_private_key" "key_sonarqube" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}


resource "local_file" "local_key_sonarqube" {
  filename        = "../sshKeys/sonarqube.key"
  content         = tls_private_key.key_sonarqube.private_key_openssh
  file_permission = "0600"
}
