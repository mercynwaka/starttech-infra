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

# --- Launch Template ---
resource "aws_launch_template" "app" {
  name_prefix   = "${var.environment}-tpl"
  image_id      = var.ami_id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = var.instance_profile_name
  }

  vpc_security_group_ids = [var.app_sg_id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "Starting User Data..."

    # 1. Update and Install Dependencies
    yum update -y
    yum install -y docker amazon-cloudwatch-agent

    # 2. Start Docker
    service docker start
    usermod -a -G docker ec2-user

    # 3. Authenticate to ECR 
    # (We inject Terraform variables directly here)
    aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${var.ecr_repository_url}

    # 4. Pull and Run Container
    docker pull ${var.ecr_repository_url}:${var.image_tag}

    # Run container mapping port 80 to the app port
    docker run -d -p 80:${var.app_port} \
      --restart always \
      --name app \
      --log-driver=awslogs \
      --log-opt awslogs-region=${var.region} \
      --log-opt awslogs-group=/aws/ec2/backend-app \
      ${var.ecr_repository_url}:${var.image_tag}

    # 5. Start CloudWatch Agent
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a fetch-config \
      -m ec2 \
      -c ssm:AmazonCloudWatch-Config \
      -s

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
