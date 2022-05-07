# region
variable "aws_region" {
  default = "eu-west-2"
}

# instance
variable "instance_instance_type" {
  # t2.medium = 2 vCPU, 4 GiB RAM
  default = "t2.medium"
}

# vpc
variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "vpc_instance_tenancy" {
  default = "default"
}

# subnet
variable "subnet_cidr_block" {
  default = "10.0.2.0/24"
}

# vm user
variable "vm_user" {
  type = string
  default = "ubuntu"
}

# cloud-init
variable "timezone" {
  default = "UTC"
}

# traefik
variable "traefik_splunk_proxy_password" {
  type = string
  description = "Password to access splunk through traefik proxy"
}

# splunk
variable "splunk_password" {
  type = string
  description = "Elastic user password, used to access kibana"
}

# cowrie
variable "cowrie_ssh_port" {
  type = string
  description = "Port for cowrie ssh service"
  default = "22"
}

variable "cowrie_telnet_port" {
  type = string
  description = "Port for cowrie telnet service"
  default = "23"
}

# ssh
variable "ssh_port" {
  type = string
  description = "Port to relocate ssh service to"
  default = "50220"
}
