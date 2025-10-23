# Lambda Execution Role
resource "aws_iam_role" "lambda_execution_role" {
  name = "PolySynergyLambdaExecution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "PolySynergy Lambda Execution Role"
    Environment = var.environment
  }
}

# Basic Lambda execution policy (CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# S3 Access Policy for Lambda
resource "aws_iam_policy" "lambda_s3_access" {
  name        = "PolySynergyLambdaS3Access"
  description = "Allow Lambda functions to access S3 buckets for file operations"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:HeadObject",
          "s3:HeadBucket"
        ],
        Resource = [
          "arn:aws:s3:::polysynergy-public-*/*",
          "arn:aws:s3:::polysynergy-private-*/*",
          "arn:aws:s3:::polysynergy-lambdas/*",
          "arn:aws:s3:::polysynergy-*-*-media/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:HeadBucket"
        ],
        Resource = [
          "arn:aws:s3:::polysynergy-public-*",
          "arn:aws:s3:::polysynergy-private-*",
          "arn:aws:s3:::polysynergy-lambdas",
          "arn:aws:s3:::polysynergy-*-*-media"
        ]
      }
    ]
  })

  tags = {
    Name        = "Lambda S3 Access Policy"
    Environment = var.environment
  }
}

# Attach S3 policy to Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_s3_access" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_s3_access.arn
}

# DynamoDB Access Policy for Lambda (for agent memory/state)
resource "aws_iam_policy" "lambda_dynamodb_access" {
  name        = "PolySynergyLambdaDynamoDBAccess"
  description = "Allow Lambda functions to access DynamoDB for agent state and memory"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ],
        Resource = [
          "arn:aws:dynamodb:*:*:table/polysynergy-*",
          "arn:aws:dynamodb:*:*:table/polysynergy-*/index/*"
        ]
      }
    ]
  })

  tags = {
    Name        = "Lambda DynamoDB Access Policy"
    Environment = var.environment
  }
}

# Attach DynamoDB policy to Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_access" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_access.arn
}

# Secrets Manager Access Policy for Lambda
resource "aws_iam_policy" "lambda_secrets_access" {
  name        = "PolySynergyLambdaSecretsAccess"
  description = "Allow Lambda functions to retrieve secrets from AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = [
          "arn:aws:secretsmanager:*:*:secret:polysynergy-*"
        ]
      }
    ]
  })

  tags = {
    Name        = "Lambda Secrets Access Policy"
    Environment = var.environment
  }
}

# Attach Secrets Manager policy to Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_secrets_access" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_secrets_access.arn
}

# ECR Access Policy for Lambda (to pull container images)
resource "aws_iam_policy" "lambda_ecr_access" {
  name        = "PolySynergyLambdaECRAccess"
  description = "Allow Lambda functions to pull container images from ECR"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "Lambda ECR Access Policy"
    Environment = var.environment
  }
}

# Attach ECR policy to Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_ecr_access" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_ecr_access.arn
}
