# # This file defines the variables used in the Terraform configuration.
# # If a variable value differs, Terraform will use the value from the root variable file (e.g., terraform.tfvars).
variable "instance_type" {
  description = "The type of instance to create"
  type        = string
  default     = "t2.micro"

}

variable "ami_id" {
  description = "The AMI ID to use for the instance"
  type        = string
  default     = "ami-084a7d336e816906b" # Amazon Linux 2023 kernel-6.1 AMI
}

variable "instance_name" {
  description = "The name of the instance"
  type        = string
  default     = "my-instance"
}
variable "bucket_name" {
  description = "The name of the S3 bucket to create."
  type        = string
  default     = "my-unique-bucket-name126487"
}
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "Terraform vpc"

}

variable "subnet_cidr" {
  description = "The CIDR block for the subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "terra-sub-pub-1"
}

variable "availability_zone" {
  description = "The availability zone for the subnet"
  type        = string
  default     = "us-east-1a"
}

variable "igw_name" {
  description = "The name of the Internet Gateway"
  type        = string
  default     = "my-igw"
}   
