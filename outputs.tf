
# === root/outputs.tf ===

output "load_balanacer_endpoint" {
  value = module.loadbalancing.lb_endpoint
}

output "instances" {
  # value = {for i in module.compute.instance: i.tags.Name => "${i.public_ip}:${module.compute.target_group_port}"}
  # OR 
  value = { for i in module.compute.instance : i.tags.Name => join(":", [i.public_ip, module.compute.target_group_port]) }
}

output "kubeconfig" {
  value = [for i in module.compute.instance : "export KUBECONFIG=${path.module}./k3s-${i.tags.Name}.yaml"]
}