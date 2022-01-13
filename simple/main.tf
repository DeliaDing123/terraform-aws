terraform {
  required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "~> 3.27"
      }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "ap-east-1"
  access_key = "xxx"
  secret_key = "xxxxxx"
}


resource "aws_instance" "app_server" {
  ami           = "ami-0e5c29e6c87a9644f"
  instance_type = "t3.micro"
  subnet_id     = "subnet-0e866e4892f775e4a"
  monitoring              = true
  tags = {
    Name = "ExampleNginxServerInstance"
  }
  user_data = file("check.sh")
}


provider "docker" {}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.latest
  name  = "nginx"
  ports {
    internal = 80
    external = 80
  }
}

