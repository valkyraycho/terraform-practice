output "address" {
  value       = module.mysql.address
  description = "Connect to the database at this endpoint"
}

output "port" {
  value       = module.mysql.port
  description = "Connect to the database at this endpoint"
}
