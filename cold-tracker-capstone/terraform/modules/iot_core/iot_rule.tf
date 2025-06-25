resource "aws_iot_topic_rule" "coldtracker_rule" {
  name        = "ColdTrackerIoTRule"
  enabled     = true
  description = "Route sensor data to Lambda when message is published on topic"

  sql = <<SQL
SELECT * FROM 'coldtracker/sensordata'
SQL

  sql_version = "2016-03-23"

  lambda {
    function_arn = aws_lambda_function.cold_tracker_lambda.arn
  }

  depends_on = [aws_lambda_permission.iot_invoke_lambda]
}
