terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

data "aws_ec2_instance_type" "instance" {
  instance_type = var.instance_type
}

resource "aws_launch_template" "example" {
  name_prefix   = "example-"
  image_id      = var.ami
  instance_type = var.instance_type

  user_data = var.user_data

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.instance.id]
  }

  lifecycle {
    create_before_destroy = true
    precondition {
      condition     = data.aws_ec2_instance_type.instance.free_tier_eligible
      error_message = "${var.instance_type} is not free tier eligible"
    }
  }
}

resource "aws_autoscaling_group" "example" {
  vpc_zone_identifier = var.subnet_ids

  target_group_arns = var.target_group_arns
  health_check_type = var.health_check_type

  min_size = var.min_size
  max_size = var.max_size

  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = {
      for key, value in var.custom_tags :
      key => upper(value)
      if key != "Name"
    }

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  lifecycle {
    postcondition {
      condition     = length(self.availability_zones) > 0
      error_message = "ASG must have at least one availability zone"
    }
  }
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count                  = var.enable_autoscaling ? 1 : 0
  autoscaling_group_name = aws_autoscaling_group.example.name
  scheduled_action_name  = "scale-out-during-business-hours"

  min_size         = 2
  max_size         = 10
  desired_capacity = 10

  recurrence = "0 9 * * *"
}
resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count                  = var.enable_autoscaling ? 1 : 0
  autoscaling_group_name = aws_autoscaling_group.example.name
  scheduled_action_name  = "scale-in-at-night"

  min_size         = 2
  max_size         = 10
  desired_capacity = 2

  recurrence = "0 17 * * *"
}


resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"
}

resource "aws_vpc_security_group_ingress_rule" "example" {
  ip_protocol       = local.tcp_protocol
  security_group_id = aws_security_group.instance.id

  cidr_ipv4 = local.all_ips
  from_port = var.server_port
  to_port   = var.server_port
}


locals {
  http_port    = 80
  tcp_protocol = "tcp"
  any_protocol = "-1"
  all_ips      = "0.0.0.0/0"
}
