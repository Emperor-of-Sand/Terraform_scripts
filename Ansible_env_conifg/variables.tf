variable "aws_region" {
  default     = "us-east-1"
  description = "AWS region"
}

variable "rhsm_username" {
  description = "Red Hat Subscription Manager username"
  type        = string
  sensitive   = true
}

variable "rhsm_password" {
  description = "Red Hat Subscription Manager password"
  type        = string
  sensitive   = true
}

variable "key_pair_name" {
  description = "Existing AWS key pair name for initial access"
  type        = string
}
variable "rhel9_ami_id" {
  description = "AMI ID for RHEL 9 in the chosen AWS region"
  type        = string
  default     = "ami-0583d8c7a9c35822c" # RHEL 9 us-east-1
}

variable "amazon_linux2_ami_id" {
  description = "AMI ID for Amazon Linux 2 in the chosen AWS region"
  type        = string
  default     = "ami-0c02fb55956c7d316" # Amazon Linux 2 us-east-1
}
variable "instance_type" {
  description = "Instance type for the control and managed nodes"
  type        = string
  default     = "t3.micro"
}