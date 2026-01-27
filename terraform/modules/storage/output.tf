output "s3_bucket_id" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.static_site.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.static_site.arn
}

output "s3_bucket_website_endpoint" {
  description = "The website endpoint (if accessing directly, though CF is preferred)"
  value       = aws_s3_bucket_website_configuration.static_site.website_endpoint
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
