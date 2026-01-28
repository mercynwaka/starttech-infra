output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets_id" {
  value = aws_subnet.public[*].id
}

output "private_subnets_id" {
  value = aws_subnet.private[*].id
}

output "app_sg_id" {
  value = aws_security_group.app_sg.id
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_profile.name
}
