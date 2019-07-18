resource "aws_cloudwatch_event_rule" "ecs_events" {
  name          = "cloudwatch-event-rule-for-${var.lambda_function_name}"
  description   = "Passes events to ${var.lambda_function_name}"
  event_pattern = var.cloudwatch_rule_event_pattern
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.ecs_events.name
  target_id = "CaptureECSEvents"
  arn       = aws_lambda_function.handler.arn
}
