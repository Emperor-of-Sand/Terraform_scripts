variable "instance_type" {
  description = "The type of instance to create"
  type        = string
  default     = "t2.micro"
  
}

variable "ami_id" {
  description = "The AMI ID to use for the instance"
  type        = string
  default     = "ami-084a7d336e816906b"  # Amazon Linux 2023 kernel-6.1 AMI
}

variable "instance_name" {
  description = "The name of the instance"
  type        = string
  default     = "my-instance"
}
