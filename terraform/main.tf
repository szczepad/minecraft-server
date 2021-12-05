terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Create a Standalone Server which is accessible on Port
# 22 and 25565
module "standalone_server" {
  source = "./modules/standalone_server"
  region = var.region
  name = var.name
  instance_type = var.instance_type
  ssh_key_name = var.ssh_key_name
}