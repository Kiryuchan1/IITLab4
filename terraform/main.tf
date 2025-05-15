provider "aws" {
  region = "eu-central-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                    = "ami-01cd11f529b248fd4"
  instance_type          = "t2.micro"
  key_name               = "keyforlab4"
  security_groups        = [aws_security_group.web_sg.name]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt update
              apt install -y docker.io
              systemctl start docker
              systemctl enable docker
              docker run -d -p 80:80 --name mywebapp kiryuchan1/mywebapp:latest
              docker run -d --name watchtower -e WATCHTOWER_WATCHDOG=true -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --interval 60
              EOF

  tags = {
    Name = "lab4-instance"
  }
}
