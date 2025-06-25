output "api_invoke_url" {
  description = "Invoke URL for the API Gateway"
  value       = module.iot_core.api_invoke_url
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.iot_core.lambda_function_arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table used for storing sensor data"
  value       = module.iot_core.dynamodb_table_name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic used for alerts"
  value       = module.iot_core.sns_topic_arn
}

output "cur_bucket_name" {
  description = "S3 bucket name for storing CUR files"
  value       = module.cur_s3_bucket.cur_bucket_name
}

output "budget_name" {
  description = "Name of the AWS Budget"
  value       = module.cost_monitoring.budget_name
}

output "glue_db_name" {
  description = "Name of the Glue database for CUR"
  value       = module.glue_athena.glue_db_name
}

output "athena_workgroup" {
  description = "Athena workgroup used for querying CUR"
  value       = module.glue_athena.athena_workgroup
}


