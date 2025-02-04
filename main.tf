# --- root/main.tf ---

module "networking" {
  source = "./networking"

  vpc_cidr  = local.vpc_cidr
  access_ip = var.access_ip

  security_groups = local.security_groups

  public_sn_count  = 2
  private_sn_count = 3
  max_subnets      = 15

  public_cidrs  = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_cidrs = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]

  db_subnet_group = true
}

module "database" {
  source = "./database"

  db_storage             = 10
  dbname                 = var.dbname
  db_engine_version      = "8.0.39"
  db_instance_class      = "db.t3.micro"
  dbuser                 = var.dbuser
  dbpassword             = var.dbpass
  db_subnet_group_name   = module.networking.db_subnet_group_name[0]
  vpc_security_group_ids = module.networking.vpc_security_group_ids
  db_identifier          = "pht-db"
  skip_db_snapshot       = true
}

module "loadbalancing" {
  source = "./loadbalancing"

  public_sg      = module.networking.public_sg
  public_subnets = module.networking.public_subnets

  vpc_id = module.networking.vpc_id

  lb_tg_port     = 8000
  lb_tg_protocol = "HTTP"

  lb_tg_healthy_threshold   = 6
  lb_tg_unhealthy_threshold = 6

  lb_tg_timeout  = 6
  lb_tg_interval = 30

  lb_listener_port     = 80
  lb_listener_protocol = "HTTP"
}

module "compute" {
  source = "./compute"

  instance_count = 2
  instance_type  = "t3.micro"

  public_subnets = module.networking.public_subnets
  public_sg      = module.networking.public_sg

  key_name        = "newkey"
  public_key_path = "${path.module}/newkey.pub"

  user_data_path = "${path.root}/scripts/userdata.tftpl"
  dbname         = var.dbname
  db_endpoint    = module.database.db_endpoint
  dbuser         = var.dbuser
  dbpass         = var.dbpass

  vol_size = 10

  private_key_path = var.private_key_path

  lb_tg_arn = module.loadbalancing.lb_tg_arn

  tg_port = 8000

}