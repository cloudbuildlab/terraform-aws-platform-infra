# Default security group for VPC
resource "aws_security_group" "default" {
  name        = "${var.vpc_name}-default"
  description = "Default security group for ${var.vpc_name}"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-default"
  })
}

# Security group for bastion hosts
resource "aws_security_group" "bastion" {
  name        = "${var.vpc_name}-bastion"
  description = "Security group for bastion hosts"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.bastion_ingress_cidr_blocks
  }

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-bastion"
  })
}
