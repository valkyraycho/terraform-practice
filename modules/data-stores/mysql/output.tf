output "address" {
  value       = aws_db_instance.example.address
  description = "Connect to the database at this endpoint"
}

output "port" {
  value       = aws_db_instance.example.port
  description = "Connect to the database at this endpoint"
}


output "arn" {
  value       = aws_db_instance.example.arn
  description = "The ARN of the database"
}
