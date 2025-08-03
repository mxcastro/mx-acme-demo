provider "aws" {
  region = "us-east-1"
}

module "acme-networking" {
  source            = "app.terraform.io/mx-acme-demo/acme-networking/aws"
  version           = "1.0.0"
  vpc_cidr          = "10.0.0.0/16"
  subnet_cidr       = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  name_prefix       = "${var.prefix}-${var.project}-${var.environment}"
}

module "acme-compute" {
  source        = "app.terraform.io/mx-acme-demo/acme-compute/aws"
  version       = "1.0.0"
  ami_id        = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"
  # instance_type     = "t2.nano" //unallowed instance type
  # instance_type     = "t3.micro" //allowed instance type
  subnet_id         = module.networking.subnet_id
  vpc_id            = module.networking.vpc_id
  name_prefix       = "${var.prefix}-${var.project}-${var.environment}"
  allowed_ports     = ["22", "443"]
  allowed_ssh_cidrs = "0.0.0.0/0"
}
