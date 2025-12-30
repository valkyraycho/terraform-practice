terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state-valkyray-187457215304"
    key    = "stage/services/webserver-cluster/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
}

module "webserver-cluster" {
  source = "git@github.com:valkyraycho/terraform-practice.git//modules/services/webserver-cluster?ref=v0.0.1"

  cluster_name           = "webservers-stage"
  db_remote_state_bucket = "terraform-up-and-running-state-valkyray-187457215304"
  db_remote_state_key    = "stage/data-stores/mysql/terraform.tfstate"

  instance_type = "t3.micro"
  min_size      = 2
  max_size      = 2
}

resource "aws_vpc_security_group_ingress_rule" "allow_testing_inbound" {
  ip_protocol       = "tcp"
  security_group_id = module.webserver-cluster.alb_security_group_id

  cidr_ipv4 = "0.0.0.0/0"
  from_port = 12345
  to_port   = 12345
}
