resource "azurerm_kubernetes_cluster" "cluster_k8sWorker" {
  name                = "k8sWorker"
  location            = azurerm_resource_group.pipeline.location
  resource_group_name = azurerm_resource_group.pipeline.name
  dns_prefix          = "k8sworkernode1"
  node_resource_group = "k8sWorker_group"

  default_node_pool {
    name                  = "default"
    node_count            = 1
    vm_size               = "Standard_D2_v2"
    enable_node_public_ip = true
  }

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_public_ip" "ip_ingress" {
  name                = "ip_ingress"
  resource_group_name = azurerm_kubernetes_cluster.cluster_k8sWorker.node_resource_group
  location            = azurerm_resource_group.pipeline.location
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on = [
    azurerm_kubernetes_cluster.cluster_k8sWorker
  ]
}