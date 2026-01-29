terraform {
  backend "s3" {
    bucket = "backend-prod-my-state-storage"
    key    = "production/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

# --- 1. Networking (VPC, Subnets, Security Groups) ---
module "networking" {
  source               = "./modules/networking"
  environment          = var.project_environment
  vpc_cidr             = var.vpc_cidr_block
  public_subnets_cidr  = var.public_subnet_cidrs
  private_subnets_cidr = var.private_subnet_cidrs
  availability_zones   = var.azs
}

# --- 2. Storage (S3 + CloudFront) ---
module "storage" {
  source      = "./modules/storage"
  environment = var.project_environment
  bucket_name = var.frontend_bucket_name

  vpc_id               = module.networking.vpc_id
  private_subnet_ids   = module.networking.private_subnets_id
  redis_sg_id          = module.networking.app_sg_id # Using the same SG for simplicity in assessment
}


# --- 3. Compute (ALB + ASG + EC2) ---
module "compute" {
  source                = "./modules/compute"
  
  # Pass the variables exactly as defined in modules/compute/variables.tf
  environment           = var.project_environment
  vpc_id                = module.networking.vpc_id
  
  # Note: passing 'public_subnet_ids' instead of 'public_subnets'
  public_subnet_ids     = module.networking.public_subnets_id
  private_subnet_ids    = module.networking.private_subnets_id
  
  app_sg_id             = module.networking.app_sg_id
  ecr_repository_url    = module.storage.ecr_repository_url
  instance_profile_name = module.networking.ec2_instance_profile_name
  
  # Optional: Override defaults if needed
  # region    = var.aws_region
  # ami_id    = "ami-..."
}

# --- 4. Monitoring (CloudWatch Dashboard) ---
module "monitoring" {
  source         = "./modules/monitoring"
  environment    = var.project_environment
  region         = var.aws_region
  bucket_name    = module.storage.bucket_name
  log_group_name = "/aws/ec2/backend-app"
}
