provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "example" {
  ami = "ami-00e428798e77d38d9"
  instance_type = "t3.micro"
  vpc_security_group_ids = [ aws_security_group.instance.id ]

  user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup python3 -m http.server 8080 &
            EOF

  user_data_replace_on_change = true

  tags = {
    "Name" = "terraform-example"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
}

resource "aws_vpc_security_group_ingress_rule" "example" {
  ip_protocol = "tcp"
  security_group_id = aws_security_group.instance.id

  cidr_ipv4 = "0.0.0.0/0"
  from_port = 8080
  to_port = 8080
}