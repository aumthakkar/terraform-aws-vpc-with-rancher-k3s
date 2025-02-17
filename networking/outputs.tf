# --- networking/outputs.tf ---

output "vpc_id" {
  value = aws_vpc.pht_vpc.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.pht_rds_subnetgroup.*.id
}

output "rds_vpc_security_group_ids" {
  value = [aws_security_group.pht_sg["rds"].id]
}

output "public_sg" {
  value = [aws_security_group.pht_sg["public"].id]
}

output "public_subnets" {
  value = aws_subnet.pht_public_subnets.*.id

}