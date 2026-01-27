variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project naming prefix"
  default     = "my-app"
}

variable "environment" {
  description = "Deployment environment (dev, stage, prod)"
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances (Amazon Linux 2 recommended)"
  # You can also use a data source to fetch the latest AMI automatically
  type = string
}

variable "ecr_repository_url" {
  description = "The URL of the ECR repository (without the tag)"
  type        = string
}

variable "image_tag" {
  description = "The Docker image tag to deploy. Change this to trigger updates."
  type        = string
  default     = "latest"
}
