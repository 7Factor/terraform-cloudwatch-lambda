terraform {
  required_version = ">=0.10.7"
}

provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

data "aws_region" "current" {}

# cloudwatch
resource "aws_cloudwatch_event_rule" "container_stopped" {
  name        = "ecs-container-stopped"
  description = "Alerts if an ECS Container unexpectedly exits."

  event_pattern = <<PATTERN
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
  rule = "${aws_cloudwatch_event_rule.container_stopped.name}"
  target_id = "SendToSNS"
  arn = "${aws_sns_topic.main.arn}"
}

# sns
data "aws_iam_policy_document" "sns-topic-policy" {
  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        "${var.sns_source_owner}",
      ]
    }

    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:sns:${data.aws_region.current.name}:${var.sns_source_owner}:${var.sns_topic_name}",
    ]
  }

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:Receive",
    ]

    condition {
      test = "StringLike"
      variable = "SNS:Endpoint"

      values = [
        "${var.sns_subscriber}",
      ]
    }

    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:sns:${data.aws_region.current.name}:${var.sns_source_owner}:${var.sns_topic_name}",
    ]

    sid = "__${var.sns_topic_name}_policy_ID"
  }
}

resource "aws_sns_topic" "main" {
  name = "${var.sns_topic_name}"
  policy = "${data.aws_iam_policy_document.sns-topic-policy.json}"
}

resource "aws_sns_topic_subscription" "sns-topic" {
  topic_arn = "${aws_sns_topic.main.arn}"
  protocol = "http"
  endpoint = "${var.sns_subscriber}"
}

variable "sns_source_owner" {
  description = "The id of the AWS account that will own the SNS topic and have publish access."
}

variable "sns_subscriber" {
  description = "The endpoint that will have access to subscribe to the SNS topic."
}

variable "sns_topic_name" {
  description = "The name of your sns topic."
}
