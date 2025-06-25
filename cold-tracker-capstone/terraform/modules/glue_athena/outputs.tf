output "glue_database_name" {
  value = aws_glue_catalog_database.cur_db.name
}

output "athena_workgroup" {
  value = aws_athena_workgroup.cur_workgroup.name
}

output "glue_db_name" {
  value       = aws_glue_catalog_database.cur_db.name
  description = "Glue database name"
}
