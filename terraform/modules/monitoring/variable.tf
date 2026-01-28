variable "environment" {
  description = "The deployment environment (e.g., production)"
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket to monitor"
  type        = string
}

variable "log_group_name" {
  description = "The CloudWatch Log Group name for the backend app"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}
