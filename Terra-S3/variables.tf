variable "bucket_name" {
  description = "The name of the S3 bucket to create."
  type        = string
  default     = "my-unique-bucket-name12648l7"
  
}

variable "region" {
  description = "The AWS region to create the S3 bucket in."
  type        = string
  default     = "us-east-1"
  
}