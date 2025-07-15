variable "bucket_name" {
  description = "정적 웹페이지 S3 버킷 이름"
  type        = string
  default     = "teammjk-static-site-bucket"
}

variable "cloudfront_comment" {
  description = "CloudFront 배포 설명"
  type        = string
  default     = "Static site for teammjk app"
}
