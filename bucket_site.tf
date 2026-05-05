resource "aws_s3_bucket" "static_site_assets" {
  bucket = "${var.project_name}-static-site-assets"
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.static_site_assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.static_site_assets.id
  key          = "index.html"
  source       = "${path.module}/app/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/app/index.html")
} 