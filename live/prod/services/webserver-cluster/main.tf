provider "aws" {
  region = "us-east-2"
}
module "webserver-cluster" {
  source = "../../../modules/services/webserver-cluster"

  server_text = "New prod server!"

  cluster_name           = "webservers-prod"
  db_remote_state_bucket = "terraform-up-and-running-state-valkyray-187457215304"
  db_remote_state_key    = "prod/data-stores/mysql/terraform.tfstate"

  instance_type      = "m4.large"
  min_size           = 2
  max_size           = 10
  enable_autoscaling = true

  custom_tags = {
    Owner     = "team-foo"
    ManagedBy = "terraform"
  }
}


