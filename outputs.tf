output "sns_topic_arns" {
  value       = aws_sns_topic.sns_topics[*].arn
  description = "ARNs of the created SNS topics"
}

output "lambda_function_arn"{
    description = "ARN of the Lambda function"
    value       = aws_lambda_function.lambda_function.arn
}

output "s3_bucket_name"{
    description = "Name of the S3 bucket"
    value       = aws_s3_bucket.bucket.id
}
