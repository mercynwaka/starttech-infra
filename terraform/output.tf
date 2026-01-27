output "application_url" {
  description = "The DNS name of the Application Load Balancer"
  value       = "http://${module.compute.alb_dns_name}"
}

output "asg_name" {
  description = "The name of the Auto Scaling Group"
  value       = module.compute.asg_name
}
