terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAQRNJR6LVTQQSSN5M"
  secret_key = "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"
}

# create a server
resource "aws_instance" "test-terra-server" {
  ami                    = "ami-04505e74c0741db8d"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1a"
  key_name               = "2nd-key-pair"
  vpc_security_group_ids = ["${aws_security_group.allow_web.id}"]
  iam_instance_profile   = aws_iam_instance_profile.Terraform_profile.name
  user_data              = <<-EOF
                #!/bin/bash
                sudo hostname Jenkins
                sudo apt update
                sudo apt install fontconfig openjdk-11-jre -y
                sudo apt install maven -y
                curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key | sudo tee \
                  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
                echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
                  https://pkg.jenkins.io/debian binary/ | sudo tee \
                /etc/apt/sources.list.d/jenkins.list > /dev/null
                sudo apt-get update
                sudo apt-get install jenkins -y
                
                EOF
  tags = {
    Name = "web server"
  }
}

# Create a security group to allow port 22,80,443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow TLS inbound traffic"

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "8080"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}
