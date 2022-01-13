output "resource_map" {
  value = {
    vm_by_name = {for vm in local.combined_vm_instances : vm.instance_name => vm}

    lb_by_name = {for lb in awscloud_clb_instance.lb_instances : lb.clb_name => lb}

    asset_id_by_name = merge({
        for vpc in awscloud_vpc.vpcs : "vpc/${vpc.name}" => vpc.id
      }, {
        for sn in awscloud_subnet.subnets : "sn/${sn.name}" => sn.id
      }, {
        for rt in awscloud_route_table.route_tables : "rt/${rt.name}" => rt.id
      }, {
        for sg in awscloud_security_group.security_groups : "sg/${sg.name}" => sg.id
      }, {
        for vm in local.combined_vm_instances : "vm/${vm.instance_name}" => vm.id
      }, {
        for lb in awscloud_clb_instance.lb_instances : "lb/${lb.clb_name}" => lb.id
      }
    )

    private_ip_by_name = merge({
        for vm in local.combined_vm_instances : vm.instance_name => vm.private_ip
      },{
        for lb in awscloud_clb_instance.lb_instances : lb.clb_name => lb.clb_vips[0]
      }
    )

    entrypoint_ip_by_name = merge({
        for vm in local.combined_vm_instances : vm.instance_name => lookup(vm, "public_ip", "")
      }, {
        for lb in awscloud_clb_instance.lb_instances : lb.clb_name => lb.clb_vips[0]
      }
    )
  }
}
