terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 1.1.0"
}

# Timing stuff
resource "time_static" "start_time" {}
resource "time_static" "end_time" {
  triggers = {
    update = length(module.provisioning.resource_map) + length(module.deployment.deployment_step_ids)
  }
}
locals {
  elapsed_time_unix    = time_static.end_time.unix - time_static.start_time.unix
  elapsed_time_hours   = floor(local.elapsed_time_unix / 3600)
  elapsed_time_minutes = floor(local.elapsed_time_unix % 3600 / 60)
  elapsed_time_seconds = local.elapsed_time_unix % 60
  elapsed_time_text    = format("%s%s%s",
    local.elapsed_time_hours > 0 ? "${local.elapsed_time_hours}h" : "",
    (local.elapsed_time_hours > 0 || local.elapsed_time_minutes > 0) ? "${local.elapsed_time_minutes}m" : "",
    "${local.elapsed_time_seconds}s"
  )
}

# Copy customized version spec files to installer directories if it exists
resource "local_file" "nginx_platform_version_spec" {
  count    = try(fileexists("${path.root}/${var.nginx_release_version}") ? 1 : 0, 0)

  content  = file("${path.root}/${var.nginx_release_version}")
  filename = "${path.root}/installer/nginx-platform/${var.nginx_release_version}"
}
resource "local_file" "nginx_system_settings_version_spec" {
  count    = try(fileexists("${path.root}/${var.nginx_release_version}") ? 1 : 0, 0)

  content  = file("${path.root}/${var.nginx_release_version}")
  filename = "${path.root}/installer/nginx-system-settings/${var.nginx_release_version}"
}

provider "awscloud" {
  secret_id  = var.secret_id
  secret_key = var.secret_key
  region     = var.region
}

module "planning" {
  source = "./module/planning"

  secret_id              = var.secret_id
  secret_key             = var.secret_key
  region                 = var.region
  availability_zones     = var.availability_zones
  initial_password       = var.initial_password
  default_nginx_port     = var.default_nginx_port
}

module "provisioning" {
  source = "./module/provisioning"

  cloud_provider               = var.cloud_provider
  nginx_release_version       = var.nginx_release_version
  nginx_settings              = var.nginx_settings
  nginx_home                  = var.nginx_home
  nginx_user                  = var.nginx_user
  initial_password             = var.initial_password
  public_key_file              = var.public_key_file
  resource_plan = module.planning.resource_plan
}

module "deployment" {
  source = "./module/deployment"

  cloud_provider               = var.cloud_provider
  nginx_release_version       = var.nginx_release_version
  nginx_settings              = var.nginx_settings
  nginx_home                  = var.nginx_home
  nginx_user                  = var.nginx_user
  initial_password             = var.initial_password
  public_key_file              = var.public_key_file
  deployment_plan   = module.planning.deployment_plan
  resource_map      = module.provisioning.resource_map
}

output "total_elapsed_time" {
  value = local.elapsed_time_text
}

output "nginx_website_url" {
  value = "http://${lookup(module.provisioning.resource_map.entrypoint_ip_by_name, module.planning.entrypoint_host_name, "")}:80"
}
