variable "environment" {
  description = "The deployment environment"
  type        = string
}

variable "bucket_name" {
  description = "Name for the frontend S3 bucket"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for Redis"
  type        = string
}

variable "private_subnet_ids" {
  description = "Subnet IDs for Redis"
  type        = list(string)
}

variable "redis_sg_id" {
  description = "Security Group ID for Redis"
  type        = string
}
