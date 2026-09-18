resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "confidential_invoices" {
  bucket = "payvault-invoices-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = {
    Classification = "Confidential"
  }
}