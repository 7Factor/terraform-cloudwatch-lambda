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