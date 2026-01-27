#!/bin/bash
echo "Starting User Data..."

# 1. Update and Install Dependencies
yum update -y
yum install -y docker amazon-cloudwatch-agent

# 2. Start Docker
service docker start
usermod -a -G docker ec2-user

# 3. Authenticate to ECR (Region is dynamic)
aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${ecr_url}

# 4. Pull and Run Container
# We map host port 80 to container port (variable)
docker pull ${ecr_url}:${image_tag}
docker run -d -p 80:${container_port} --restart always --name app ${ecr_url}:${image_tag}

# 5. Start CloudWatch Agent (Basic configuration)

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c ssm:AmazonCloudWatch-Config \
  -s

echo "User Data Complete."
