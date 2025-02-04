# === database/main.tf ====


resource "aws_db_instance" "pht_db" {
  allocated_storage      = var.db_storage # 10
  db_name                = var.dbname
  engine                 = "mysql"
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  username               = var.dbuser
  password               = var.dbpassword
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  identifier             = var.db_identifier
  skip_final_snapshot    = var.skip_db_snapshot

  tags = {
    Name = "pht-mysql-db"
  }
}