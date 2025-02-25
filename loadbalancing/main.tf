
# === loadbalancing/main.tf ====

resource "aws_lb" "pht_lb" {
  name = "pht-load-balancer"

  internal           = false
  load_balancer_type = "application"

  security_groups = var.public_sg
  #subnets            = [for subnet in aws_subnet.pht_public_subnets  : subnet.id]
  subnets = var.public_subnets

  idle_timeout = 360 # 6 mins
}

resource "aws_lb_target_group" "pht_tg" {
  name = "pht-lb-tg-${substr(uuid(), 0, 4)}"

  vpc_id = var.vpc_id

  port     = var.lb_tg_port     # 80 for prod but used 8000 here
  protocol = var.lb_tg_protocol # HTTP

  health_check {
    healthy_threshold   = var.lb_tg_healthy_threshold   # 2
    unhealthy_threshold = var.lb_tg_unhealthy_threshold # 2

    timeout  = var.lb_tg_timeout  # 3
    interval = var.lb_tg_interval # 30
  }

  lifecycle {
    ignore_changes        = [name] # Used to avoid creating a new tg due to uuid() interpolated in the name
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "pht_lb_listener" {
  load_balancer_arn = aws_lb.pht_lb.arn

  port     = var.lb_listener_port     # 80
  protocol = var.lb_listener_protocol # HTTP

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pht_tg.arn
  }
}