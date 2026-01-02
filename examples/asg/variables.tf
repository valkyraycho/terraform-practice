variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type        = string
  default     = "example"
}

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t3.micro)"
  type        = string
  default     = "t3.micro"
}
