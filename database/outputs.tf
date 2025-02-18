
# === database/outputs.tf ====

output "db_endpoint" {
  value = aws_db_instance.pht_db.endpoint
}