output "name" {
  value = azurerm_postgresql_flexible_server.postgresql_flexible_server.name
}

output "id" {
  value = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
}

output "fqdn" {
  description = "Fully qualified domain name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.postgresql_flexible_server.fqdn
}

output "identity" {
  description = "Managed identity attributes exported by the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.postgresql_flexible_server.identity
}

output "dbs" {
  description = "dbs"
  value       = [for dbs in azurerm_postgresql_flexible_server_database.postgresql_flexible_db : dbs.id]
}

output "configs" {
  description = "configs"
  value       = [for configs in azurerm_postgresql_flexible_server_configuration.postgresql_configuration : configs.id]
}