resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
  statement_id  = "AllowExecutionFromCloudWatch-for-${var.lambda_function_name}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.handler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecs_events.arn
}

resource "aws_lambda_function" "handler" {
  s3_bucket = var.lambda_s3_bucket
  s3_key    = var.lambda_s3_key

  function_name = var.lambda_function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = var.lambda_handler
  description   = var.lambda_description

  publish = var.lambda_publish

  runtime = var.lambda_runtime

  tracing_config {
    mode = var.lambda_tracing_config_mode
  }

  environment {
    variables = var.lambda_environment_vars
  }
}