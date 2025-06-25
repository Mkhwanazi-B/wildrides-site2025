resource "aws_cloudwatch_dashboard" "finops_dashboard" {
  dashboard_name = "ColdTracker-FinOps-Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        "type" : "metric",
        "x" : 0,
        "y" : 0,
        "width" : 12,
        "height" : 6,
        "properties" : {
          "metrics" : [
            [ "AWS/Lambda", "Invocations", "FunctionName", "ColdTrackerHandler" ],
            [ ".", "Errors", ".", "." ]
          ],
          "period" : 300,
          "stat" : "Sum",
          "region" : var.aws_region,
          "title" : "Lambda Invocations & Errors"
        }
      },
      {
        "type" : "metric",
        "x" : 0,
        "y" : 7,
        "width" : 12,
        "height" : 6,
        "properties" : {
          "metrics" : [
            [ "AWS/Billing", "EstimatedCharges", "Currency", "USD" ]
          ],
          "period" : 21600,
          "stat" : "Maximum",
          "region" : "us-east-1",
          "title" : "Estimated AWS Charges"
        }
      }
    ]
  })
}
