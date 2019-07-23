resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
  statement_id  = "AllowExecutionFromCloudWatch-for-${var.lambda_function_name}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.handler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecs_events.arn
}

resource "aws_lambda_function" "handler" {
  s3_bucket         = var.lambda_s3_bucket
  s3_key            = var.lambda_s3_key
  s3_object_version = var.lambda_s3_object_version

  function_name = var.lambda_function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = var.lambda_handler
  description   = var.lambda_description

  publish = var.lambda_publish

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256(var.lambda_s3_key)

  runtime = var.lambda_runtime

  tracing_config {
    mode = var.lambda_tracing_config_mode
  }

  environment {
    variables = var.lambda_environment_vars
  }
}