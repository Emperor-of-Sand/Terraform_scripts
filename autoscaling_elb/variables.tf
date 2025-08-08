
# Variables
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "instance_type" {
  default = "t3.micro"
}

variable "ami_id" {
  default = "ami-0263dd5562cf9d185" # Amazon Linux 2 AMI
}

variable "region" {
  default = "us-east-1"
}
