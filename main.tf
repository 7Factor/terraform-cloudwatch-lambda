terraform {
  required_version = ">=0.12.3"
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
        "${var.webhook_url}",
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
  protocol = "lambda"
  endpoint = "${aws_lambda_function.sns_handler.arn}"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_${var.sns_topic_name}_lambda"
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

resource "aws_lambda_function" "sns_handler" {
  filename      = "lambda.zip"
  function_name = "${var.lambda_function_name}"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "${var.lambda_handler}"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = "${filebase64sha256("lambda.zip")}"

  runtime = "python3.7"

  environment {
    variables = {
      slack_channel = "${var.slack_channel}"
      hook_url      = "${var.webhook_url}"
    }
  }
}

variable "sns_source_owner" {
  description = "The id of the AWS account that will own the SNS topic and have publish access."
}

variable "sns_topic_name" {
  description = "The name of your sns topic."
}

variable "lambda_function_name" {
  description = "The name of your lambda function"
}

variable "lambda_handler" {
  description = "The name of your lambda handler. Format is <FILE>.<HANDLER>"
}

variable "slack_channel" {
  description = "The channel you want messages to be posted to."
}

variable "webhook_url" {
  description = "The webhook_url from your Slack app."
}
