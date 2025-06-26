
resource "aws_secretsmanager_secret" "coldtracker_secrets" {
  for_each = var.coldtracker_secrets

  name = each.key
}
  
resource "aws_secretsmanager_secret_version" "coldtracker_secrets_value" {
  for_each = var.coldtracker_secrets

  secret_id     = aws_secretsmanager_secret.coldtracker_secrets[each.key].id
  secret_string = each.value
}
