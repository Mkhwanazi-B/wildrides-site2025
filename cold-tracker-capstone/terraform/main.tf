provider "aws" {
  region = var.aws_region
}

data "aws_s3_object" "lambda_zip" {
  bucket = var.lambda_code_bucket
  key    = var.lambda_code_key
}


# IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}

# Attach AWSLambdaBasicExecutionRole for CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create a custom policy for Lambda to access DynamoDB and SNS
resource "aws_iam_policy" "lambda_ddb_sns_policy" {
  name = "LambdaDynamoSNSPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem"
        ],
        Resource = aws_dynamodb_table.cold_tracker_data.arn
      },
      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = aws_sns_topic.cold_alerts.arn
      }
    ]
  })
}

# Attach the custom policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_ddb_sns_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_ddb_sns_policy.arn
}

# DynamoDB Table for sensor data
resource "aws_dynamodb_table" "cold_tracker_data" {
  name         = "ColdTrackerData"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "sensor_id"
  range_key    = "timestamp"

  attribute {
    name = "sensor_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }
}

# SNS Topic for cold alerts
resource "aws_sns_topic" "cold_alerts" {
  name = "ColdAlertsTopic"
}
resource "aws_sns_topic_subscription" "cold_alert_sms" {
  topic_arn = aws_sns_topic.cold_alerts.arn
  protocol  = "sms"
  endpoint  = "+27619124822"
}


# Lambda Function
resource "aws_lambda_function" "cold_tracker_lambda" {
  function_name = "ColdTrackerHandler"
  handler       = "index.handler"
  runtime       = "nodejs16.x"

  s3_bucket = var.lambda_code_bucket
  s3_key    = var.lambda_code_key



  role = aws_iam_role.lambda_exec_role.arn

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.cold_tracker_data.name
      SNS_TOPIC_ARN  = aws_sns_topic.cold_alerts.arn
    }
  }
  source_code_hash = data.aws_s3_object.lambda_zip.etag
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "cold_tracker_api" {
  name        = "ColdTrackerAPI"
  description = "API Gateway for Cold Tracker sensor simulator"
}

# API Gateway Resource Path: /sensor-data
resource "aws_api_gateway_resource" "sensor_data" {
  rest_api_id = aws_api_gateway_rest_api.cold_tracker_api.id
  parent_id   = aws_api_gateway_rest_api.cold_tracker_api.root_resource_id
  path_part   = "sensor-data"
}

# POST method on /sensor-data
resource "aws_api_gateway_method" "post_sensor_data" {
  rest_api_id   = aws_api_gateway_rest_api.cold_tracker_api.id
  resource_id   = aws_api_gateway_resource.sensor_data.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integration with Lambda
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.cold_tracker_api.id
  resource_id             = aws_api_gateway_resource.sensor_data.id
  http_method             = aws_api_gateway_method.post_sensor_data.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.cold_tracker_lambda.invoke_arn
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "apigw_invoke_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cold_tracker_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.cold_tracker_api.execution_arn}/*/*"
}

# Deploy the API Gateway
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.cold_tracker_api.id
  description = "Deployment for ColdTrackerAPI"
}

# Define the stage separately (outside of deployment block)
resource "aws_api_gateway_stage" "prod" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.cold_tracker_api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
}

module "iot_core" {
  source             = "./modules/iot_core"
  aws_region         = var.aws_region
  lambda_code_bucket = var.lambda_code_bucket
  lambda_code_key    = var.lambda_code_key
}
# Add any other variables your module expects

module "cur_s3_bucket" {
  source          = "./modules/s3_cur_bucket"
  cur_bucket_name = "coldtracker-cur-${var.environment}"
  environment     = var.environment
}

module "cost_monitoring" {
  source          = "./modules/cost_monitoring"
  cur_bucket_name = module.cur_s3_bucket.cur_bucket_name
  environment     = var.environment
  aws_region      = var.aws_region
}



resource "aws_cur_report_definition" "coldtracker_cur" {
  report_name                = "coldtracker-cur-report"
  time_unit                  = "HOURLY"
  format                     = "textORcsv"
  compression                = "GZIP"
  additional_schema_elements = ["RESOURCES"]
  s3_bucket                  = module.cur_s3_bucket.cur_bucket_name
  s3_region                  = var.aws_region
  s3_prefix                  = "cur/"
  report_versioning          = "OVERWRITE_REPORT"
  depends_on                 = [module.cur_s3_bucket]
}

module "glue_athena" {
  source          = "./modules/glue_athena"
  cur_bucket_name = module.cur_s3_bucket.cur_bucket_name
  environment     = var.environment
}
