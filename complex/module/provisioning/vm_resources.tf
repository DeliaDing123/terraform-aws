locals {
  private_key_pem = try(file(pathexpand(trimsuffix(var.public_key_file, ".pub"))), null)
  key_name        = try(awscloud_key_pair.nginx_installer[0].id, null)
  password        = local.key_name == null ? var.initial_password : null
}

resource "awscloud_key_pair" "nginx_installer" {
  count = try(fileexists(pathexpand(var.public_key_file)) ? 1 : 0, 0)

  key_name   = "nginx_installer"
  public_key = file(pathexpand(var.public_key_file))
}

resource "awscloud_instance" "vm_instances" {
  count = local.is_aws_cloud_enabled ? length(var.resource_plan.vm_instances) : 0

  vpc_id                     = nginx.vpcs[0].id
  availability_zone          = var.resource_plan.vm_instances[count.index].availability_zone
  subnet_id                  = local.subnet_id_map[var.resource_plan.vm_instances[count.index].subnet_name]
  instance_name              = var.resource_plan.vm_instances[count.index].name
  instance_type              = var.resource_plan.vm_instances[count.index].instance_type
  image_id                   = var.resource_plan.vm_instances[count.index].image_id
  system_disk_type           = var.resource_plan.vm_instances[count.index].system_disk_type
  system_disk_size           = var.resource_plan.vm_instances[count.index].system_disk_size
  key_name                   = local.key_name
  password                   = local.password
  private_ip                 = var.resource_plan.vm_instances[count.index].private_ip
  allocate_public_ip         = var.resource_plan.vm_instances[count.index].allocate_public_ip
  internet_max_bandwidth_out = var.resource_plan.vm_instances[count.index].allocate_public_ip ? var.resource_plan.vm_instances[count.index].internet_max_bandwidth_out : null
  security_groups            = awscloud_security_group.security_groups.*.id

  connection {
    type         = "ssh"
    bastion_host = local.bastion_host_ip
    host         = local.use_bastion_host ? self.private_ip : self.public_ip
    user         = "root"
    private_key  = local.private_key_pem
    password     = self.password
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${var.wecube_home}/installer"
    ]
  }

  provisioner "file" {
    source      = "${path.root}/installer/"
    destination = "${var.wecube_home}/installer"
  }

  provisioner "file" {
    content = <<-EOT
      DATE_TIME='${timestamp()}'
      HOST_PRIVATE_IP='${var.resource_plan.vm_instances[count.index].private_ip}'
      WECUBE_RELEASE_VERSION='${var.wecube_release_version}'
      WECUBE_SETTINGS='${var.wecube_settings}'
      WECUBE_HOME='${var.wecube_home}'
      WECUBE_USER='${var.wecube_user}'
      INITIAL_PASSWORD='${var.initial_password}'
      USE_MIRROR_IN_MAINLAND_CHINA='${var.use_mirror_in_mainland_china}'

      # Network
      VPC_CIDR_IP=${var.resource_plan.vpcs[0].cidr_block}

      # Proxy
      PROXY_HOST=${local.proxy_host_ip}
      PROXY_PORT=3128

      # Docker
      DOCKER_PORT=2375

    EOT
    destination = "${var.wecube_home}/installer/provisioning.env"
  }

  provisioner "remote-exec" {
    inline = [
      "find ${var.wecube_home}/installer -name \"*.sh\" -exec chmod +x {} +",
      "find ${var.wecube_home}/installer -name \"*.env\" -exec chmod 600 {} +",
      "${var.wecube_home}/installer/invoke-installer.sh ${var.wecube_home}/installer/provisioning.env ${join(" ", var.resource_plan.vm_instances[count.index].provisioned_with)}"
    ]
  }
}

resource "awscloud_clb_instance" "lb_instances" {
  count = local.is_aws_cloud_enabled ? length(var.resource_plan.lb_instances) : 0
  depends_on = [awscloud_instance.vm_instances]

  vpc_id       = nginx.vpcs[0].id
  subnet_id    = local.subnet_id_map[var.resource_plan.lb_instances[count.index].subnet_name]
  clb_name     = var.resource_plan.lb_instances[count.index].name
  network_type = var.resource_plan.lb_instances[count.index].network_type
  project_id   = 0
}
