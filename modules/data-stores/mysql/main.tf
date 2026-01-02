terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


resource "aws_db_instance" "example" {
  instance_class      = "db.t3.micro"
  identifier_prefix   = "terraform-up-and-running"
  allocated_storage   = 10
  skip_final_snapshot = true

  engine   = var.replicate_source_db == null ? "mysql" : null
  db_name  = var.replicate_source_db == null ? var.db_name : null
  username = var.replicate_source_db == null ? var.db_username : null
  password = var.replicate_source_db == null ? var.db_password : null

  backup_retention_period = var.backup_retention_period
  replicate_source_db     = var.replicate_source_db
}
