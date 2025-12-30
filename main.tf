provider "aws" {
  region = "us-east-2"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
}

resource "aws_vpc_security_group_ingress_rule" "example" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.instance.id

  cidr_ipv4 = "0.0.0.0/0"
  from_port = var.server_port
  to_port   = var.server_port
}

resource "aws_lb" "example" {
  name               = "terraform-asg-example"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  protocol          = "HTTP"
  port              = 80

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
  name = "terraform-example-alb"
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.alb.id

  cidr_ipv4 = "0.0.0.0/0"
  from_port = 80
  to_port   = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_http" {
  ip_protocol       = "-1"
  security_group_id = aws_security_group.alb.id

  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_lb_target_group" "asg" {
  name     = "terraform-asg-example"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

resource "aws_launch_template" "example" {
  name_prefix   = "example-"
  image_id      = "ami-00e428798e77d38d9"
  instance_type = "t3.micro"

  user_data = base64encode(<<-EOF
      #!/bin/bash
      echo "Hello, World" > index.html
      nohup python3 -m http.server ${var.server_port} &
    EOF
  )

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.instance.id]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  vpc_zone_identifier = data.aws_subnets.default.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }

  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }
}



variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}


output "alb_dns_name" {
  value       = aws_lb.example.dns_name
  description = "The domain name of the load balancer"
}
