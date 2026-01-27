 variable "project_name" {
  description = "The project name, used for naming resources and the S3 bucket"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Redis placement"
  type        = list(string)
}

variable "redis_security_group_id" {
  description = "Security Group ID allowing access to Redis (port 6379)"
  type        = string
}

variable "cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution (for S3 bucket policy)"
  type        = string
}
