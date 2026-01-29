# --- Application Load Balancer (ALB) ---
resource "aws_lb" "main" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.app_sg_id]
  subnets            = var.public_subnet_ids  # UPDATED NAME

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "app" {
  name     = "${var.environment}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = "/health"
    interval            = 30
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}


    
# 1. Find the latest Amazon Linux 2023 AMI 
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"] # Filter for Amazon Linux 2023
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --- Launch Template ---
resource "aws_launch_template" "app" {
  name_prefix   = "${var.environment}-tpl"
  
  # Use the Amazon Linux AMI ID found above
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = var.instance_profile_name
  }

  vpc_security_group_ids = [var.app_sg_id]

  # USER DATA FOR AMAZON LINUX (yum works here!)
  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "Starting User Data..."

    # 1. Update and Install Docker
    yum update -y
    yum install -y docker

    # 2. Start Docker
    service docker start
    systemctl enable docker
    usermod -a -G docker ec2-user

    # 3. Authenticate to ECR
    
    aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${var.ecr_repository_url}

    # 4. Pull and Run Container
    docker pull ${var.ecr_repository_url}:${var.image_tag}

    docker run -d -p 80:${var.app_port} \
      --restart always \
      --name app \
      --log-driver=awslogs \
      --log-opt awslogs-region=${var.region} \
      --log-opt awslogs-group=/aws/ec2/backend-app \
      --log-opt awslogs-create-group=true \
      ${var.ecr_repository_url}:${var.image_tag}

    echo "User Data Complete."
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment}-backend-node"
    }
  }
}
    

# --- Auto Scaling Group ---
resource "aws_autoscaling_group" "app" {
  name                = "${var.environment}-asg"
  vpc_zone_identifier = var.private_subnet_ids # UPDATED NAME
  target_group_arns   = [aws_lb_target_group.app.arn]
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
}
