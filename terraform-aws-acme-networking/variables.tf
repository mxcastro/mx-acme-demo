variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "subnet_cidr" {
  type        = string
  description = "Subnet CIDR block"
}

variable "availability_zone" {
  type        = string
  description = "Availability Zone"
}

variable "name_prefix" {
  type        = string
  description = "Name prefix for resources"
}
