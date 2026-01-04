variable "db_username" {
  description = "The username for the database"
  type        = string
  sensitive   = true
  default     = null
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
  default     = null
}

variable "db_name" {
  description = "The name to use for the database"
  type        = string
  default     = null
}

variable "backup_retention_period" {
  description = "Days to retain backups. Must be > 0 to enable replication"
  type        = number
  default     = null
}

variable "replicate_source_db" {
  description = "If specified, replicate the RDS database at the given ARN"
  type        = string
  default     = null
}

variable "publicly_accessible" {
  description = "If true, the database will be publicly accessible"
  type        = bool
  default     = false
}
