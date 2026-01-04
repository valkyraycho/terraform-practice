output "address" {
  value       = module.mysql_db.address
  description = "Connect to the database at this endpoint"
}

output "port" {
  value       = module.mysql_db.port
  description = "Connect to the database at this endpoint"
}
