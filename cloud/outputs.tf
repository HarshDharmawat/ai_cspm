output "ecr_repository_url" {
  value = aws_ecr_repository.payvault_repo.repository_url
  description = "Target ECR registry URI"
}

output "web_public_ip" {
  value = aws_instance.web.public_ip
  description = "Public IP for Web node"
}

output "db_public_ip" {
  value = aws_instance.db.public_ip
  description = "Public IP for Database node"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.confidential_invoices.id
  description = "Target confidential S3 bucket"
}