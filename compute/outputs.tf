output "instance" {
  value = aws_instance.pht_node[*]

}

output "target_group_port" {
  value = aws_lb_target_group_attachment.pht_tg_attach[0].port
}