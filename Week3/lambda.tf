resource "aws_lambda_function" "myfunct" {
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  function_name    = "myfunct"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "funct.lambda_handler"
  runtime          = "python3.10"
}

# IAM role for Lambda function execution
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_policy" "iam_policy_resume_challenge" {
  name        = "aws_iam_policy_terraform_resume_project_policy"
  description = "IAM policy for DynamoDB access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action : [
          "dynamodb:*"
        ],
        Resource = "arn:aws:dynamodb:*:*:table/views_table"
      }
    ],
  })
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_role" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.iam_policy_resume_challenge.arn
}

data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/"
  output_path = "${path.module}/lambda/packedlambda.zip"
}
