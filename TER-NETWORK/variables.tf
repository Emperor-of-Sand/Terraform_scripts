variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
  
}

variable "public_subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
  
}

variable "private_subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.2.0/24"
  
}

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
  
}

variable "az" {
    description = "Availability Zone for the resources"
    type        = string
    default     = "us-east-1a"
}