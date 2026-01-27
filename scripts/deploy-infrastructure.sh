#!/bin/bash
set -e

# ==========================================
# Infrastructure Deployment Script
# Usage: ./deploy-infrastructure.sh <environment> <action>
# Example: ./deploy-infrastructure.sh prod apply
# ==========================================

ENV=$1
ACTION=$2
TF_DIR="../terraform"

if [ -z "$ENV" ] || [ -z "$ACTION" ]; then
    echo "Usage: $0 <environment> <plan|apply|destroy>"
    exit 1
fi

echo "--- Starting Infrastructure Deployment: $ENV ($ACTION) ---"

cd "$TF_DIR"

# 1. Initialize Terraform
echo "Step 1: Initializing Terraform..."
terraform init

# 2. Select/Create Workspace (Optional but good practice for multi-env)
# echo "Step 2: Selecting Workspace..."
# terraform workspace select "$ENV" || terraform workspace new "$ENV"

# 3. Validate Configuration
echo "Step 2: Validating Terraform Configuration..."
terraform validate

# 4. Execute Action
case $ACTION in
    plan)
        echo "Step 3: Running Plan..."
        terraform plan -var-file="$ENV.tfvars" -out=tfplan
        ;;
    apply)
        echo "Step 3: Applying Configuration..."
        # Note: We assume the plan was reviewed in a PR or previous step
        terraform apply -auto-approve -var-file="$ENV.tfvars"
        ;;
    destroy)
        echo "WARNING: Destroying Infrastructure..."
        terraform destroy -auto-approve -var-file="$ENV.tfvars"
        ;;
    *)
        echo "Invalid action: $ACTION"
        exit 1
        ;;
esac

echo "--- Operation $ACTION Complete ---"
