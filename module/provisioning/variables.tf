variable "cloud_provider" {}
variable "nginx_release_version" {}
variable "nginx_settings" {}
variable "nginx_home" {}
variable "nginx_user" {}
variable "initial_password" {}
variable "public_key_file" {}
variable "use_mirror_in_mainland_china" {}

variable "resource_plan" {}


locals {
  is_aws_cloud_enabled = var.cloud_provider == "AwsCloud"

  subnet_id_map = {for s in awscloud_subnet.subnets : s.name => s.id}

  use_bastion_host = length(var.resource_plan.bastion_hosts) > 0

  combined_vm_instances = awscloud_instance.vm_instances
}
