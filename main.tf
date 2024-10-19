# Create SNS topics
resource "aws_sns_topic" "sns_topics"{
    count = length(var.sns_topic_names)
    name = var.sns_topic_names[count.index]
}

# Create S3 bucket
resource "aws_s3_bucket" "bucket"{
    bucket = var.s3_bucket_name
}

# Create IAM role for lambda
resource "aws_iam_role" "lambda_role"{
    name = "${var.lambda_function_name}-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
            },
        ]
    })

}

# Create IAM policy for lambda
resource "aws_iam_policy" "lambda_policy"{
    name = "${var.lambda_function_name}-policy"
    description = "Policy for ${var.lambda_function_name}"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents",
                ]
                Effect = "Allow"
                Resource = "*"
            },
            {
                Action = [
                    "s3:PutObject",
                ]
                Effect = "Allow"
                Resource = [
                    aws_s3_bucket.bucket.arn,
                    "${aws_s3_bucket.bucket.arn}/*",
                ]
            },
        ]
    })
}

# Attach policy to role
resource "aws_iam_policy_attachment" "lambda_policy_attach"{
    name  = "lambda-policy-attachment"
    roles = [aws_iam_role.lambda_role.name]
    policy_arn = aws_iam_policy.lambda_policy.arn
}

# Create Lambda function
resource "aws_lambda_function" "lambda_function"{
    filename = "${path.module}/lambda_function_1/target/lambda_function_1-1.0-SNAPSHOT.jar"
    function_name = var.lambda_function_name
    handler = "com.example.SNSEventHandler::handleRequest"
    runtime = "java17"
    role    = aws_iam_role.lambda_role.arn
    timeout = 30
    memory_size = 1024
    source_code_hash = filebase64sha256("${path.module}/lambda_function_1/target/lambda_function_1-1.0-SNAPSHOT.jar")
}

# Subscribe Lambda to SNS topics
resource "aws_sns_topic_subscription" "sns_subscriptions"{
    count = length(var.sns_topic_names)
    topic_arn = aws_sns_topic.sns_topics[count.index].arn
    protocol = "lambda"
    endpoint = aws_lambda_function.lambda_function.arn
}

# Allow SNS to invoke Lambda
resource "aws_lambda_permission" "allow_sns_invoke"{
    count = length(var.sns_topic_names)
    statement_id = "AllowExecutionFromSNS${count.index}"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda_function.function_name
    principal = "sns.amazonaws.com"
    source_arn = aws_sns_topic.sns_topics[count.index].arn
}

