bucket = "terraform-up-and-running-state-valkyray-187457215304"
key    = "stage/data-stores/mysql/terraform.tfstate"
region = "us-east-2"

dynamodb_table = "terraform-up-and-running-locks"
encrypt        = true