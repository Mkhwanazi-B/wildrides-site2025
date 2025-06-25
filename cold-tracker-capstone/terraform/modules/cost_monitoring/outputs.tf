output "cur_bucket_name" {
  description = "CUR bucket name (passed from s3_cur_bucket module)"
  value       = var.cur_bucket_name
}

output "budget_name" {
  description = "Name of the AWS budget"
  value       = aws_budgets_budget.monthly_cost_budget.name
}
