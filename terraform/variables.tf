variable "region" {
  description = "Region in which the Server should be created"
  type = string
}

variable "name" {
  description = "Name of the Resources"
  type = string
}

variable "instance_type" {
  description = "Type of EC2 Instance"
  type = string
}

variable "ssh_key_name" {
  description = "Name of the SSH-Key in AWS which should be used for the Instance"
  type = string
}