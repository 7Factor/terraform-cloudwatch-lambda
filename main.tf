terraform {
  required_version = ">=0.10.7"
}

provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

data "aws_region" "current" {}

# cloudwatch
resource "aws_cloudwatch_event_rule" "ecs_events" {
  name        = "cloudwatch-event-rule"
  description = "Test rule for ecs events."

  event_pattern = <<PATTERN
{
  "source": [
    "aws.ecs"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule = aws_cloudwatch_event_rule.ecs_events.name
  target_id = "CaptureECSEvents"
  arn = aws_lambda_function.handler.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.handler.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.ecs_events.arn
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_${var.lambda_handler}_lambda"
  description = "Allows Lambda Function to call AWS services on your behalf."

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "handler" {
  filename      = "lambda.zip"
  function_name = var.lambda_function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = var.lambda_handler

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("lambda.zip")

  runtime = "python3.7"

  environment {
    variables = {
      hook_url      = var.webhook_url
    }
  }
}

variable lambda_function_name {
  description = "The name of your lambda function"
}

variable lambda_handler {
  description = "The name of your lambda handler. Format is <FILE>.<HANDLER>"
}

variable "webhook_url" {
  description = "The webhook_url from your Slack app."
}
