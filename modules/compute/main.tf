resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.instance.id]

  tags = {
    Name = "${var.name_prefix}-instance"
  }
}

resource "aws_security_group" "instance" {
  name        = "${var.name_prefix}-sg"
  description = "Allow Ports"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "instance" {
  for_each          = toset(var.allowed_ports)
  security_group_id = aws_security_group.instance.id
  cidr_ipv4         = var.allowed_ssh_cidrs
  from_port         = tonumber(each.value)
  to_port           = tonumber(each.value)
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "instance" {
  security_group_id = aws_security_group.instance.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 0
  ip_protocol = "tcp"
  to_port     = 0
}
