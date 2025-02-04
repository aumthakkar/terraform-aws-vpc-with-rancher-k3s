# === loadbalancing/variables.tf ====

variable "public_sg" {}
variable "public_subnets" {}

variable "vpc_id" {}
variable "lb_tg_port" {}
variable "lb_tg_protocol" {}
variable "lb_tg_healthy_threshold" {}
variable "lb_tg_unhealthy_threshold" {}
variable "lb_tg_timeout" {}
variable "lb_tg_interval" {}

variable "lb_listener_port" {}
variable "lb_listener_protocol" {}