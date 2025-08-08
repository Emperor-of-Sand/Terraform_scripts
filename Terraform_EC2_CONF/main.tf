provider "aws" {
  region = "us-west-2"

}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-Terraform-vpc"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "my-Terraform-subnet"
  }

}

resource "aws_instance" "MyEc2" {
  ami           = "ami-04e08e36e17a21b56" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id

  vpc_security_group_ids = [aws_security_group.my_sg.id]

  user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World!" > /var/www/html/index.html
                EOF

  tags = {
    Name = "my-Terraform-EC2"
  }

  root_block_device {
    volume_size           = 10
    volume_type           = "gp2"
    delete_on_termination = true
  }

}

resource "aws_security_group" "my_sg" {
  name        = "my-instance-sg"
  description = "Security group for my EC2 instance"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
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

# resource "aws_s3_bucket" "mys3bucket" {
#   bucket = "my-s3-bucket123m456"
# }

terraform {
  backend "s3" {
    bucket = "my-s3-bucket123m456"
    key    = "my-s3-bucket123m456/statefiles/state.tf"
    region = "us-west-2"
  }
}
