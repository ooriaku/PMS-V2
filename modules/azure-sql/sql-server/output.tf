
output "db_id" {
  value = azurerm_mssql_database.sql-db.id
}

output "server_id" {
  description = "The server Id of the newly created sql server"
  value       = azurerm_mssql_server.sql.*.id[*] 
}

output "server_name" {
  description = "The server name of the newly created sql server"
  value       = azurerm_mssql_server.sql.*.name[*] 
}

output "fqdn" {
	description = "The fully qualified domain name of the newly created sql server"
	value		= azurerm_mssql_server.sql.*.fully_qualified_domain_name[*]
}
