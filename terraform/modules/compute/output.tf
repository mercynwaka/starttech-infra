
output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "asg_name" {
  value = aws_autoscaling_group.app.name
}
