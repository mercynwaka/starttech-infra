variable "environment" {
  description = "The deployment environment (e.g., production)"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where resources will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of Public Subnet IDs for the ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of Private Subnet IDs for the ASG"
  type        = list(string)
}

variable "app_sg_id" {
  description = "Security Group ID for the Application/EC2"
  type        = string
}

variable "ecr_repository_url" {
  description = "URL of the ECR repository"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM Instance Profile name for EC2"
  type        = string
}

variable "app_port" {
  description = "Port the application runs on"
  type        = number
  default     = 8080
}

# --- Defaults to prevent "Missing Argument" errors ---

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances (Default: Amazon Linux 2 in us-east-1)"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" 
}

variable "image_tag" {
  description = "Tag of the Docker image to deploy"
  type        = string
  default     = "latest"
}
