terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "aws_lb" "example" {
  name               = var.alb_name
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  protocol          = "HTTP"
  port              = local.http_port

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_security_group" "alb" {
  name = "${var.alb_name}-alb"
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  ip_protocol       = local.tcp_protocol
  security_group_id = aws_security_group.alb.id

  cidr_ipv4 = local.all_ips
  from_port = local.http_port
  to_port   = local.http_port
}

resource "aws_vpc_security_group_egress_rule" "alb_http" {
  ip_protocol       = local.any_protocol
  security_group_id = aws_security_group.alb.id

  cidr_ipv4 = local.all_ips
}


locals {
  http_port    = 80
  tcp_protocol = "tcp"
  any_protocol = "-1"
  all_ips      = "0.0.0.0/0"
}
