output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}
output "kube_config" {
  value = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive = true
}

output "timestamp" {
  value = formatdate("MM-DD", timestamp())
}