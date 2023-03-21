terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.44.1"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "pipeline" {
  name     = var.rgname
  location = var.location
}

resource "azurerm_virtual_network" "vnet0" {
  name                = "${azurerm_resource_group.pipeline.name}-vnet0"
  location            = azurerm_resource_group.pipeline.location
  resource_group_name = azurerm_resource_group.pipeline.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "s0" {
  name                 = "${azurerm_virtual_network.vnet0.name}-s0"
  address_prefixes     = ["10.0.0.0/24"]
  resource_group_name  = azurerm_resource_group.pipeline.name
  virtual_network_name = azurerm_virtual_network.vnet0.name
}

resource "azurerm_subnet" "s1" {
  name                                      = "${azurerm_virtual_network.vnet0.name}-s1"
  address_prefixes                          = ["10.0.1.0/24"]
  resource_group_name                       = azurerm_resource_group.pipeline.name
  virtual_network_name                      = azurerm_virtual_network.vnet0.name
  private_endpoint_network_policies_enabled = true
}

resource "azurerm_subnet" "s2" {
  name                 = "${azurerm_virtual_network.vnet0.name}-s2"
  address_prefixes     = ["10.0.2.0/24"]
  resource_group_name  = azurerm_resource_group.pipeline.name
  virtual_network_name = azurerm_virtual_network.vnet0.name
}

resource "azurerm_subnet" "s3" {
  name                 = "${azurerm_virtual_network.vnet0.name}-s3"
  address_prefixes     = ["10.0.3.0/24"]
  resource_group_name  = azurerm_resource_group.pipeline.name
  virtual_network_name = azurerm_virtual_network.vnet0.name
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "${azurerm_resource_group.pipeline.name}-vnet1"
  location            = azurerm_resource_group.pipeline.location
  resource_group_name = azurerm_resource_group.pipeline.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "s4" {
  name                 = "${azurerm_virtual_network.vnet1.name}-s0"
  address_prefixes     = ["10.1.0.0/24"]
  resource_group_name  = azurerm_resource_group.pipeline.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
}

resource "azurerm_network_security_group" "nsg_blockSubnetInterconnections" {
  name                = "nsg_blockSubnetInterconnections"
  resource_group_name = azurerm_resource_group.pipeline.name
  location            = azurerm_resource_group.pipeline.location


  security_rule {
    name                   = "DenyOthersToJenkins"
    priority               = 100
    direction              = "Inbound"
    access                 = "Deny"
    protocol               = "*"
    source_port_range      = "*"
    destination_port_range = "*"
    source_address_prefixes = [
      azurerm_subnet.s1.address_prefixes.0,
      azurerm_subnet.s2.address_prefixes.0,
      azurerm_subnet.s3.address_prefixes.0
    ]
    destination_address_prefix = azurerm_subnet.s0.address_prefixes.0
  }


  security_rule {
    name                   = "DenyOthersToSonarqube"
    priority               = 101
    direction              = "Inbound"
    access                 = "Deny"
    protocol               = "*"
    source_port_range      = "*"
    destination_port_range = "*"
    source_address_prefixes = [
      azurerm_subnet.s0.address_prefixes.0,
      azurerm_subnet.s2.address_prefixes.0,
      azurerm_subnet.s3.address_prefixes.0
    ]
    destination_address_prefix = azurerm_subnet.s1.address_prefixes.0
  }


  security_rule {
    name                   = "DenyOthersToAnsible"
    priority               = 102
    direction              = "Inbound"
    access                 = "Deny"
    protocol               = "*"
    source_port_range      = "*"
    destination_port_range = "*"
    source_address_prefixes = [
      azurerm_subnet.s0.address_prefixes.0,
      azurerm_subnet.s1.address_prefixes.0,
      azurerm_subnet.s3.address_prefixes.0
    ]
    destination_address_prefix = azurerm_subnet.s2.address_prefixes.0
  }


  security_rule {
    name                   = "DenyOthersTok8sMaster"
    priority               = 103
    direction              = "Inbound"
    access                 = "Deny"
    protocol               = "*"
    source_port_range      = "*"
    destination_port_range = "*"
    source_address_prefixes = [
      azurerm_subnet.s0.address_prefixes.0,
      azurerm_subnet.s1.address_prefixes.0,
      azurerm_subnet.s2.address_prefixes.0
    ]
    destination_address_prefix = azurerm_subnet.s3.address_prefixes.0
  }
}

resource "azurerm_subnet_network_security_group_association" "asnsga_blockJenkinsInbound" {
  subnet_id                 = azurerm_subnet.s0.id
  network_security_group_id = azurerm_network_security_group.nsg_blockSubnetInterconnections.id
}

resource "azurerm_subnet_network_security_group_association" "asnsga_blockSonarqubeInbound" {
  subnet_id                 = azurerm_subnet.s1.id
  network_security_group_id = azurerm_network_security_group.nsg_blockSubnetInterconnections.id
}

resource "azurerm_subnet_network_security_group_association" "asnsga_blockAnsibleInbound" {
  subnet_id                 = azurerm_subnet.s2.id
  network_security_group_id = azurerm_network_security_group.nsg_blockSubnetInterconnections.id
}

resource "azurerm_subnet_network_security_group_association" "asnsga_blockk8sMasterInbound" {
  subnet_id                 = azurerm_subnet.s3.id
  network_security_group_id = azurerm_network_security_group.nsg_blockSubnetInterconnections.id
}

resource "azurerm_storage_account" "sa1" {
  name                     = "sa1nlptjrbeqcblkwjgqsme"
  resource_group_name      = azurerm_resource_group.pipeline.name
  location                 = azurerm_resource_group.pipeline.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"
  account_kind             = "BlobStorage"
  blob_properties {
    delete_retention_policy {
      days = 60
    }
    container_delete_retention_policy {
      days = 7
    }
  }
}

resource "azurerm_storage_container" "sc1" {
  name                  = "trivy-reports"
  storage_account_name  = azurerm_storage_account.sa1.name
  container_access_type = "container"
}
