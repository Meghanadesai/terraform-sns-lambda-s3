variable "aws_region" {
  default     = "us-east-1"
  description = "AWS Region"
}

variable "sns_topic_names"{
    description = "List of SNS topic names"
    type = list(string)
    default = ["topic1","topic2","topic3"]
}

variable "s3_bucket_name"{
    description = "Name of the S3 bucket"
    type = string
    default = "my-sns-lambda-bucket"
}

variable "lambda_function_name"{
    description = "Name of the Lambda function"
    type = string
    default = "sns-to-s3-function"
}