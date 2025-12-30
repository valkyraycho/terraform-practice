terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state-valkyray-187457215304"
    key    = "stage/data-stores/mysql/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_db_instance" "example" {
  instance_class      = "db.t3.micro"
  identifier_prefix   = "terraform-up-and-running"
  engine              = "mysql"
  allocated_storage   = 10
  db_name             = var.db_name
  skip_final_snapshot = true

  username = var.db_username
  password = var.db_password
}
