resource "aws_s3_bucket" "this" {
  bucket = "${var.name}-${var.bucket_name}-${var.env}"

  tags = {
    Name = "${var.name}-${var.bucket_name}-bucket-${var.env}"
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}
