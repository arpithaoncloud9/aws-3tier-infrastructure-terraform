output "db_endpoint" {
  description = "RDS MySQL endpoint"
  value       = aws_db_instance.mariaDB.address
}

output "db_port" {
  description = "RDS MySQL port"
  value       = aws_db_instance.mariaDB.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.mariaDB.db_name
}


