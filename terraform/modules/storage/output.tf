output "bucket_name" {
  description = "The name of the S3 bucket"
  # FIXED: Matches the resource name 'frontend' and variable name expected by root main.tf
  value       = aws_s3_bucket.frontend.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  
  value       = aws_s3_bucket.frontend.arn
}


output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend.id
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "redis_primary_endpoint" {
  description = "The primary endpoint address for Redis"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "The reader endpoint address for Redis"
  value       = aws_elasticache_replication_group.redis.reader_endpoint_address
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.app_repo.repository_url
}
