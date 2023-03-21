output "public_ip_jenkins" {
  value = azurerm_linux_virtual_machine.vm_jenkins.public_ip_address
}
output "public_ip_vault" {
  value = azurerm_linux_virtual_machine.vm_vault.public_ip_address
}
output "public_ip_sonarqube" {
  value = azurerm_linux_virtual_machine.vm_sonarqube.public_ip_address
}
output "public_ip_ansible" {
  value = azurerm_linux_virtual_machine.vm_ansible.public_ip_address
}
output "public_ip_k8smaster" {
  value = azurerm_linux_virtual_machine.vm_k8sMaster.public_ip_address
}
output "public_endpoint" {
  value = azurerm_public_ip.ip_ingress.ip_address
}
