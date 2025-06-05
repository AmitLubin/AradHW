provider "aws" {
  region = "il-central-1"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket        = "amit-host-bucket"
  force_destroy = true # Allows Terraform to delete the bucket even if it contains objects
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "pblock" {
  bucket = aws_s3_bucket.website_bucket.id
  
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read_policy" {
    bucket = aws_s3_bucket.website_bucket.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Sid       = "PublicReadGetObject"
            Effect    = "Allow"
            Principal = "*"
            Action    = "s3:GetObject"
            Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
        }
        ]
    })

    depends_on = [aws_s3_bucket_public_access_block.pblock]
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website_bucket.bucket
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.website_bucket.bucket
  key          = "error.html"
  source       = "error.html"
  content_type = "text/html"
}

output "website_url" {
  value = "${aws_s3_bucket.website_bucket.bucket}.s3-website.${aws_s3_bucket.website_bucket.region}.amazonaws.com"
}