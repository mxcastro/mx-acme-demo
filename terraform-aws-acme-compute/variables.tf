variable "allowed_ports" {
  type    = list(string)
  default = ["80", "443"]
}

variable "allowed_ssh_cidrs" {
  default = "0.0.0.0/0"
}

variable "name_prefix" {}
variable "ami_id" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "vpc_id" {}


