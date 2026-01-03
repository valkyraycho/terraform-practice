variable "server_text" {
  description = "The text the web server should return"
  type        = string
  default     = "Hello, World!"
}

variable "environment" {
  description = "The name of the environment we're deploying to"
  type        = string
  default     = "example"
}

variable "mysql_config" {
  description = "The configuration for the MySQL database"
  type = object({
    address = string
    port    = number
  })
  default = {
    address = "mock-mysql-address"
    port    = 12345
  }
}
