provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = "event-announcement-site-bucket"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = "*",
      Action = "s3:GetObject",
      Resource = "arn:aws:s3:::event-announcement-site-bucket/*"
    }]
  })
}

resource "aws_sns_topic" "subscriber_topic" {
  name = "event-notifications"
}

resource "aws_lambda_function" "event_registration" {
  function_name = "event_registration_lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "event_registration_lambda.lambda_handler"
  runtime       = "python3.9"
  filename      = "event_registration_lambda.zip"
  source_code_hash = filebase64sha256("event_registration_lambda.zip")

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.website_bucket.bucket
    }
  }
}

resource "aws_lambda_function" "subscription" {
  function_name = "subscription_lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "subscription_lambda.lambda_handler"
  runtime       = "python3.9"
  filename      = "subscription_lambda.zip"
  source_code_hash = filebase64sha256("subscription_lambda.zip")

  environment {
    variables = {
      TOPIC_ARN = aws_sns_topic.subscriber_topic.arn
    }
  }
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "EventAPI"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "prod"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "event_register_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.event_registration.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "event_register_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /new-event"
  target    = "integrations/${aws_apigatewayv2_integration.event_register_integration.id}"
}

resource "aws_apigatewayv2_integration" "subscribe_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.subscription.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "subscribe_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /subscribers"
  target    = "integrations/${aws_apigatewayv2_integration.subscribe_integration.id}"
}

resource "aws_lambda_permission" "allow_apigw_event" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.event_registration.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_apigw_subscribe" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.subscription.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

