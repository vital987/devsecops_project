output "public_ip_jenkins" {
  value = azurerm_linux_virtual_machine.vm_jenkins.public_ip_address
}
output "public_ip_vault" {
  value = azurerm_linux_virtual_machine.vm_vault.public_ip_address
}
output "public_ip_ansible" {
  value = azurerm_linux_virtual_machine.vm_ansible.public_ip_address
}
output "private_ip_ansible" {
  value = azurerm_linux_virtual_machine.vm_ansible.private_ip_address
}
output "private_ip_jenkins" {
  value = azurerm_linux_virtual_machine.vm_jenkins.private_ip_address
}
output "private_ip_k8sMaster" {
  value = azurerm_linux_virtual_machine.vm_k8sMaster.private_ip_address
}
output "private_ip_vault" {
  value = azurerm_linux_virtual_machine.vm_vault.private_ip_address
}
output "public_endpoint" {
  value = azurerm_public_ip.ip_ingress.ip_address
}