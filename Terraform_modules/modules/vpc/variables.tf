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