provider "aws" {
  region = var.aws_region
}

module "networking" {
  source = "./modules/networking"

  # Left side: Variable name defined inside modules/networking/variables.tf
  # Right side: Variable name defined in root variables.tf
  environment          = var.project_environment
  vpc_cidr             = var.vpc_cidr_block
  public_subnets_cidr  = var.public_subnet_cidrs
  private_subnets_cidr = var.private_subnet_cidrs
  availability_zones   = var.azs

  vpc_id               = module.networking.vpc_id

}
# --- storage ---
module "storage" {
  source = "./modules/storage"

  project_name            = "my-golang-app"
  private_subnet_ids      = module.networking.private_subnets
  redis_security_group_id = module.security.redis_sg_id
  
  # This creates an implicit dependency. 
  # Terraform usually handles this fine, but ensure your CloudFront 
  # module outputs the ARN correctly.
  cloudfront_distribution_arn = module.cdn.cloudfront_distribution_arn
}

# --- 3. Compute Module ---
# Creates ASG, ALB, Launch Template
module "compute" {
  source = "./modules/compute"

  # General
  project_name = var.project_name
  environment  = var.environment
  region       = var.aws_region

  # Network Inputs (From Networking Module)
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids

  # Security Inputs (From Security Module)
  app_sg_id = module.security.app_sg_id
  alb_sg_id = module.security.alb_sg_id

  # Application Specifics
  ami_id             = var.ami_id
  instance_type      = "t3.small"
  min_size           = 2
  max_size           = 5
  desired_capacity   = 2
  
  # Container / ECR Details
  ecr_repository_url = var.ecr_repository_url
  image_tag          = var.image_tag     # Update this var to trigger rolling updates!
  container_port     = 3000              # Port your app listens on inside Docker
}

# 4. --- monitoring ---

provider "aws" {
  region = "us-east-1"
}

# Calling the module
module "frontend_app" {
  source = "./modules/frontend"

  # Passing values into the variables we defined
  bucket_name    = "my-company-app-bucket-prod-01"
  log_group_name = "/aws/app/frontend-prod"
  environment    = "production"
}
