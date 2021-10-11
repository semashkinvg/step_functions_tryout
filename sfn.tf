resource "aws_iam_role" "iam_for_sfn" {
  name = "iam_for_sfn"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "iam_for_sfn_lambda_attachment" {
  role       = aws_iam_role.iam_for_sfn.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
}

resource "aws_iam_role_policy_attachment" "iam_for_sfn_cw_attachment" {
  role       = aws_iam_role.iam_for_sfn.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_cloudwatch_log_group" "sfn_log_group" {
  name = "sfn_log_group"

  tags = {
    Environment = "production"
    Application = "serviceA"
  }
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "my-state-machine"
  role_arn = aws_iam_role.iam_for_sfn.arn
  logging_configuration {
    level = "ALL"
    include_execution_data = true
    log_destination = "${aws_cloudwatch_log_group.sfn_log_group.arn}:*"
  }
  depends_on = [
    aws_iam_role_policy_attachment.iam_for_sfn_cw_attachment,
    aws_iam_role_policy_attachment.iam_for_sfn_lambda_attachment
  ]
  type     = "EXPRESS"

  definition = <<EOF
{
  "Comment": "A Hello World example of the Amazon States Language using an AWS Lambda Function",
  "StartAt": "HelloWorld",
  "States": {
    "HelloWorld": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.test_lambda.arn}",
      "End": true
    }
  }
}
EOF
}