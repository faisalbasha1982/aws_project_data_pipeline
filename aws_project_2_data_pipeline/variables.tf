provider "aws" {
  region = "us-east-1"
}

# Parameterized bucket names
variable "raw_bucket_name" {
  description = "Name of the raw data S3 bucket"
  default     = "csv-raw-data"
}
variable "processed_bucket_name" {
  description = "Name of the processed data S3 bucket"
  default     = "csv-processed-data"
}
variable "final_bucket_name" {
  description = "Name of the final data S3 bucket"
  default     = "csv-final-data"
}
