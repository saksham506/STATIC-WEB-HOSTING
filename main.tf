
locals {
  content_types = {
    html = "text/html"
    css  = "text/css"
    js   = "application/javascript"

    png  = "image/png"
    jpg  = "image/jpeg"
    jpeg = "image/jpeg"
    gif  = "image/gif"
    svg  = "image/svg+xml"
    webp = "image/webp"
    ico  = "image/x-icon"
  }
}

# creating s3 bucket
resource "aws_s3_bucket" "bucket-1" {
  bucket = "terraform-bucket-static-web-hosting-12345"
}
# enabling public access
resource "aws_s3_bucket_public_access_block" "public-access-block" {
  bucket = aws_s3_bucket.bucket-1.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
# upload multiple objects to s3 bucket
resource "aws_s3_object" "multiple-objects" {
  bucket = "terraform-bucket-static-web-hosting-12345"
  for_each = fileset("C:/Users/User/Downloads/2160_exhibit_studio/2160_exhibit_studio","**")
  key  = each.value
  source = "C:/Users/User/Downloads/2160_exhibit_studio/2160_exhibit_studio/${each.value}"
  # it will fetches each object annd assinging content type based on file extension
  content_type = lookup(
    local.content_types,
    lower(element(split(".", each.value), length(split(".", each.value)) - 1)),
    "application/octet-stream"
  )
}
# enabling static web hosting
resource "aws_s3_bucket_website_configuration" "website-configuration" {
  bucket = aws_s3_bucket.bucket-1.id

  index_document {
    suffix = "index.html"
  }
}
# creating s3 bucket ploicy
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.bucket-1.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.bucket-1.arn,
      "${aws_s3_bucket.bucket-1.arn}/*",
    ]
  }
}