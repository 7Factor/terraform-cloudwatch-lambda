# cloudwatch alarm
resource "aws_cloudwatch_event_rule" "container_stopped" {
  name        = "ecs-container-stopped"
  description = "Alerts if an ECS Container unexpectedly exits."

  schedule_expression = <<PATTERN
{
  "source": ["aws.ecs"],
  "detail-type": ["ECS Task State Change"],
  "detail": {
    "lastStatus": ["STOPPED"],
    "stoppedReason" : ["Essential container in task exited"]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "sns" {
  arn = ""
  rule = "${aws_cloudwatch_event_rule.container_stopped.name}"
  target_id = "SendToSNS"
}

# sns
resource "aws_sns_topic" "task_stopped_alert" {
  name = "task-stopped-alert"
}

# lambda function
