terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
# Store Terraform state in S3
terraform {
  backend "s3" {
    bucket  = "my-terraform-state-bucket45621"
    key     = "my-terraform-state-bucket45621/backend/backend.tf"
    region  = "us-east-1"
    encrypt = true
  }
}

module "ec2_instance" {
  source = "./modules/ec2"
  ami_id = var.ami_id
  instance_type = var.instance_type
  instance_name = var.instance_name
}

module "vpc" {
  source = "./modules/vpc"
  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr
  subnet_cidr = var.subnet_cidr
  availability_zone = var.availability_zone
  subnet_name = var.subnet_name
  igw_name = var.igw_name
}

module "s3" {
  source = "./modules/s3"
  bucket_name = var.bucket_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
output "subnet_id" {
  value = module.vpc.subnet_id
  
}
output "internet_gateway_id" {
  value = module.vpc.internet_gateway_id
}