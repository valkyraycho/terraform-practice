variable "alb_name" {
  type        = string
  description = "The name of the ALB"
}

variable "subnet_ids" {
  description = "The subnets to use for the ALB"
  type        = list(string)
}
