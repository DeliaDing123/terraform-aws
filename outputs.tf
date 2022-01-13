output "bastion_host_name" {
  value = local.eks_mode ? local.bastion_hosts_cluster[0].name : null
}

output "resource_plan" {
  value = {
    vpcs                 = local.eks_mode ? [local.vpc_cluster]                : [local.vpc_standalone]
    subnets              = local.eks_mode ? local.subnets_cluster              : [local.subnet_standalone]
    route_tables         = local.eks_mode ? [local.route_table_cluster]        : [local.route_table_standalone]
    security_groups      = local.eks_mode ? [local.security_group_cluster]     : [local.security_group_standalone]
    security_group_rules = local.eks_mode ? local.security_group_rules_cluster : local.security_group_rules_standalone
    vm_instances         = local.eks_mode ? local.hosts_cluster                : [local.host_standalone]
    lb_instances         = local.eks_mode ? local.lb_instances_cluster         : []
  }
}

output "deployment_plan" {
  value = local.eks_mode ? local.deployment_plan_cluster : local.deployment_plan_standalone
}

output "entrypoint_host_name" {
  value = local.eks_mode ? local.lb_internal_1_cluster.name : local.host_standalone.name
}
