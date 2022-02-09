####################################################################################################
# Secret database master credentials
####################################################################################################
data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = "db_credentials"
}

locals {
  db_credentials = jsondecode(
    data.aws_secretsmanager_secret_version.db_credentials.secret_string
  )
}

####################################################################################################
# Lambda application to delete all posts from ghost
####################################################################################################
resource "aws_iam_role" "ec2_iam_role" {
  name = "ec2_iam_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2-read-only-policy-attachment" {
    role = "${aws_iam_role.ec2_iam_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vpc-full-access-policy-attachment" {
    role = "${aws_iam_role.ec2_iam_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_lambda_function" "delete_all_posts" {
  filename      = "./aws/lambda/src.zip"
  function_name = "delete_ghost_posts"
  role          = aws_iam_role.ec2_iam_role.arn
  handler       = "index.handler"

  source_code_hash = filebase64sha256("./aws/lambda/src.zip")

  runtime = "nodejs12.x"

  vpc_config {
    subnet_ids         = var.aws_subnet_public_subnet_ids
    security_group_ids = [var.aws_security_group_application_id]
  }

  environment {
    variables = {
      database_username = local.db_credentials.username,
      database_password = local.db_credentials.password,
      database_endpoint = var.aws_rds_cluster_mysql_endpoint
    }
  }
}