# Terraform code to provision AWS resources for the Event Announcement System

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "event_site" {
  bucket = "event-announcement-site-bucket"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.event_site.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = "*",
      Action = ["s3:GetObject"],
      Resource = ["${aws_s3_bucket.event_site.arn}/*"]
    }]
  })
}

resource "aws_iam_role" "lambda_role" {
  name = "event_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_sns_topic" "event_notifications" {
  name = "event-notifications"
}

resource "aws_lambda_function" "subscription_lambda" {
  filename         = "subscription_lambda.zip"
  function_name    = "subscriptionLambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "subscription_lambda.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("subscription_lambda.zip")
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.event_notifications.arn
    }
  }
}

resource "aws_lambda_function" "event_registration_lambda" {
  filename         = "event_registration_lambda.zip"
  function_name    = "eventRegistrationLambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "event_registration_lambda.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("event_registration_lambda.zip")
  environment {
    variables = {
      BUCKET_NAME    = aws_s3_bucket.event_site.bucket,
      EVENTS_FILE    = "events.json",
      SNS_TOPIC_ARN  = aws_sns_topic.event_notifications.arn
    }
  }
}

resource "aws_api_gateway_rest_api" "event_api" {
  name = "event-api"
}

resource "aws_api_gateway_resource" "subscribers" {
  rest_api_id = aws_api_gateway_rest_api.event_api.id
  parent_id   = aws_api_gateway_rest_api.event_api.root_resource_id
  path_part   = "subscribers"
}

resource "aws_api_gateway_resource" "new_event" {
  rest_api_id = aws_api_gateway_rest_api.event_api.id
  parent_id   = aws_api_gateway_rest_api.event_api.root_resource_id
  path_part   = "new-event"
}

# Additional API Gateway + Integration + Deployment resources should be added here
# (for brevity, left as a placeholder)

output "s3_website_url" {
  value = aws_s3_bucket.event_site.website_endpoint
}

output "sns_topic_arn" {
  value = aws_sns_topic.event_notifications.arn
}
