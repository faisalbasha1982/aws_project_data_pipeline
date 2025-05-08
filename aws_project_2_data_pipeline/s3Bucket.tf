resource "aws_s3_bucket" "raw_bucket" {
  bucket = var.raw_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket" "processed_bucket" {
  bucket = var.processed_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket" "final_bucket" {
  bucket = var.final_bucket_name
  force_destroy = true
}
