variable "cloud_provider" {
  description = "Specify the public cloud provider used to create resources"
  default     = "AwsCloud"
}

variable "secret_id" {
  description = "Secret id used when connecting to the public cloud provider"
}

variable "secret_key" {
  description = "Secret key used when connecting to the public cloud provider"
}

variable "region" {
  description = "The region of the public cloud where resources are to be created"
  default     = "ap-east"
}

variable "availability_zones" {
  description = "The availability zones in the region where resources are to be created (STANDALONE mode will be used if SINGLE AZ is specified and CLUSTER mode will be used for 2 AZs)"
  type        = list(string)
  default     = [
    "ap-east-1b"
  ]
}

variable "nginx_release_version" {
  description = "The WeCube release version on GitHub that we use to determine target versions of specific components to be installed.\nValid options:\n- \"latest\" (latest release version)\n- \"v2.7.1\" (specific release version)\n- \"customized\" (using a customized version spec file)"
  default     = "latest"
}

variable "nginx_settings" {
  description = "Set of features provided by plugins and best practices desired during installation.\nValid options:\n- \"standard\" (complete plugin installation and configurations)\n- \"bootcamp\" (used for bootcamp tutorial)\n- \"empty\" (no plugin will be installed)"
  default     = "standard"
}

variable "nginx_home" {
  description = "The installation root directory of WeCube on the host"
  default     = "/data/wecube"
}

variable "nginx_user" {
  description = "The user to run WeCube"
  default     = "centos"
}

variable "initial_password" {
  description = "The initial password of root user on hosts and MySQL instances"
  default     = "nginx@123456"
}

variable "public_key_file" {
  description = "Public key file for ssh login"
  default     = ""#"~/.ssh/id_rsa.pub"
}

variable "nginx_port" {
  description = "The listening port of MySQL instances"
  default     = "80"
}

