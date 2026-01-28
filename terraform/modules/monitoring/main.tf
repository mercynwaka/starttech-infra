resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.environment}-dashboard"

  # This reads the JSON file from the root 'monitoring' folder
  # We use templatefile() to inject dynamic values into the JSON
  dashboard_body = templatefile("${path.module}/../../../monitoring/cloudwatch-dashboard.json", {
    region         = var.region
    log_group_name = var.log_group_name
    bucket_name    = var.bucket_name
    environment    = var.environment
  })
}

# Optional: Add a standard alarm for High CPU
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.environment}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  
  # Note: Ideally you pass the ASG Name here, but for now we filter by tag
  dimensions = {
    AutoScalingGroupName = "${var.environment}-asg" 
  }
}
