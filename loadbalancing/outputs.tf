output "lb_tg_arn" {
  value = aws_lb_target_group.pht_tg.arn
}

output "lb_endpoint" {
  value = aws_lb.pht_lb.dns_name
}