
# === compute/variables.tf ====

variable "instance_count" {}
variable "instance_type" {}
variable "public_subnets" {}
variable "public_sg" {}
variable "vol_size" {}
variable "key_name" {}
variable "public_key_path" {}

variable "user_data_path" {}
variable "dbname" {}
variable "db_endpoint" {}
variable "dbuser" {}
variable "dbpass" {}

variable "private_key_path" {}

variable "lb_tg_arn" {}

variable "tg_port" {}