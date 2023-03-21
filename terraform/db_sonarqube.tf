resource "random_string" "db_suffix" {
  length  = 5
  lower   = true
  upper   = false
  numeric = false
  special = false
}

resource "azurerm_postgresql_server" "db1" {
  name                             = "db-sonarqube-${random_string.db_suffix.result}"
  location                         = azurerm_resource_group.pipeline.location
  resource_group_name              = azurerm_resource_group.pipeline.name
  administrator_login              = "sonarqube"
  administrator_login_password     = var.psql_passwd
  sku_name                         = "GP_Gen5_2"
  version                          = "11"
  storage_mb                       = 5120
  backup_retention_days            = 7
  geo_redundant_backup_enabled     = false
  auto_grow_enabled                = false
  public_network_access_enabled    = false
  ssl_enforcement_enabled          = false
  ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
}

resource "azurerm_private_endpoint" "db_pe" {
  name                = "db_endpoint"
  location            = azurerm_resource_group.pipeline.location
  resource_group_name = azurerm_resource_group.pipeline.name
  subnet_id           = azurerm_subnet.s1.id

  private_service_connection {
    name                           = "db_pe_pvc"
    private_connection_resource_id = azurerm_postgresql_server.db1.id
    is_manual_connection           = false
    subresource_names              = ["postgresqlServer"]
  }

  ip_configuration {
    name               = "db_pe_ipconfig"
    private_ip_address = "10.0.1.5"
    subresource_name   = "postgresqlServer"
  }
}

data "azurerm_private_endpoint_connection" "db_pec" {
  name                = azurerm_private_endpoint.db_pe.name
  resource_group_name = azurerm_resource_group.pipeline.name
}
