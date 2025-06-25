resource "aws_budgets_budget" "monthly_cost_budget" {
  name         = "ColdTrackerMonthlyCostBudget-${var.environment}"
  budget_type  = "COST"
  limit_amount = "100"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "FORECASTED"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    subscriber_email_addresses = ["your-email@example.com"]
  }

  cost_types {
    include_tax           = true
    include_subscription  = true
    use_blended           = false
  }

  tags = {
    Environment = var.environment
  }
}
