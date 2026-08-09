variable "bucket_name" {

  description = "Name of the S3 bucket"
  type        = string
  default     = "nimbus-customer-docs"
}

variable "environment" {
    
  description = "Deployment environment"
  type        = string
  default     = "prod"
}