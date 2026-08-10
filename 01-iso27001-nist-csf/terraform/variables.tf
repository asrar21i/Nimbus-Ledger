variable "aws_region" {
  type        = string
  description = "AWS region for infrastructure resources"
  default     = "us-east-1"
}

variable "bucket_name" {
  type        = string
  description = "Name for the S3 bucket"
  default     = "nimbus-ledger-customer-docs-bucket"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
  default     = "production"
}

variable "db_password" {
  type        = string
  description = "Master password for RDS instance (supply via TF_VAR_db_password or CI secret, never commit a default)"
  sensitive   = true
  
}