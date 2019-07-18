data "aws_iam_policy" "lambda_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "xray_write_access" {
  arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

resource "aws_iam_role" "iam_for_lambda" {
  name        = "iam_for_${var.lambda_handler}_lambda"
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

resource "aws_iam_role_policy_attachment" "lambda_execution_role_attachment" {
  policy_arn = data.aws_iam_policy.lambda_execution_role.arn
  role = aws_iam_role.iam_for_lambda.name
}

resource "aws_iam_role_policy_attachment" "xray_write_access_attachment" {
  policy_arn = data.aws_iam_policy.xray_write_access.arn
  role = aws_iam_role.iam_for_lambda.name
}
