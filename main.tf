data "aws_region" "current" {}

# cloudwatch
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
  rule      = "${aws_cloudwatch_event_rule.container_stopped.name}"
  target_id = "SendToSNS"
  arn       = "${aws_sns_topic.main.arn}"
}

# sns
resource "aws_sns_topic" "main" {
  name = "task-stopped-alert"

  policy = <<EOF
{
  "Version": "2008-10-17",

  "Statement": [
    {
      "Effect": "Allow",
      "Id": "publish_policy",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "SNS:Publish",
        "SNS:RemovePermission",
        "SNS:SetTopicAttributes",
        "SNS:DeleteTopic",
        "SNS:ListSubscriptionsByTopic",
        "SNS:GetTopicAttributes",
        "SNS:Receive",
        "SNS:AddPermission",
        "SNS:Subscribe"
      ],
      "Resource": "arn:aws:sns:${data.aws_region.current.name}:${var.sns_source_owner}:new-topic",
      "Condition": {
        "StringEquals": {
          "AWS:SourceOwner": "${var.sns_source_owner}"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "SNS:Subscribe",
        "SNS:Receive"
      ],
      "Resource": "arn:aws:sns:${data.aws_region.current.name}:${var.sns_source_owner}:new-topic",
      "Condition": {
        "StringLike": {
          "SNS:Endpoint": "${var.sns_subscriber}"
        }
      }
    }
  ]
}
EOF
}

variable "sns_source_owner" {
  description = "The id of the AWS account that will own the SNS topic and have publish access."
}

variable "sns_subscriber" {
  description = "The endpoint that will have access to subscribe to the SNS topic."
}
