variable "name" {
  description = "The name to use for all resources created by this module"
  type        = string
}


variable "image" {
  description = "The Docker image to run in the ECS cluster"
  type        = string

}


variable "container_port" {
  description = "The port the Docker image is running on"
  type        = number
}

variable "replicas" {
  description = "The number of Docker containers to run"
  type        = number
}

variable "environment_variables" {
  description = "The environment variables to pass to the Docker image"
  type        = map(string)
  default     = {}
}
