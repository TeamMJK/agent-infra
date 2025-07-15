output "bucket_name" {
  value       = aws_s3_bucket.website.id
  description = "정적 사이트 S3 버킷 이름"
}

output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.cdn.domain_name
  description = "CloudFront 도메인 이름(`xxx.cloudfront.net`)"
}

output "cloudfront_distribution_id" {
  value       = aws_cloudfront_distribution.cdn.id
  description = "CloudFront 배포 ID"
}
