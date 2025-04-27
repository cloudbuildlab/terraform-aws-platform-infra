locals {
  vpc_name_prefix = "${var.environment}-${var.name_prefix}"
}

module "external_vpc" {
  source  = "cloudbuildlab/vpc/aws"
  version = ">= 1.0.8"

  vpc_name = "${local.vpc_name_prefix}-external"
  vpc_cidr = var.external_vpc_cidr

  # DNS Configuration
  enable_dns_hostnames = true
  enable_dns_support   = true

  availability_zones = var.availability_zones

  # Subnet Configuration
  public_subnet_cidrs  = var.external_public_subnet_cidrs
  private_subnet_cidrs = var.external_private_subnet_cidrs

  # NAT Gateway always enabled for external
  enable_nat_gateway = true
  nat_gateway_type   = var.nat_gateway_type
  enable_nacls       = false

  tags = merge(var.tags, {
    Network = "external"
  })
}

module "internal_vpc" {
  source  = "cloudbuildlab/vpc/aws"
  version = ">= 1.0.8"

  vpc_name = "${local.vpc_name_prefix}-internal"
  vpc_cidr = var.internal_vpc_cidr

  # DNS Configuration
  enable_dns_hostnames = true
  enable_dns_support   = true

  availability_zones = var.availability_zones

  # Subnet Configuration
  private_subnet_cidrs = var.internal_private_subnet_cidrs

  # NAT Gateway always disabled for internal
  enable_nat_gateway = false
  enable_nacls       = false

  tags = merge(var.tags, {
    Network = "internal"
  })
}

# VPC Peering Connection
resource "aws_vpc_peering_connection" "external_to_internal" {
  vpc_id      = module.external_vpc.vpc_id
  peer_vpc_id = module.internal_vpc.vpc_id
  auto_accept = true

  tags = merge(var.tags, {
    Name = "external-to-internal"
  })
}

# Route table updates to route traffic through External VPC
resource "aws_route" "internal_to_external_cidr" {
  count                     = length(module.internal_vpc.private_route_table_ids)
  route_table_id            = module.internal_vpc.private_route_table_ids[count.index]
  destination_cidr_block    = var.external_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.external_to_internal.id
}

# Route table updates to route internet traffic through External VPC
resource "aws_route" "internal_to_external" {
  count                     = length(module.internal_vpc.private_route_table_ids)
  route_table_id            = module.internal_vpc.private_route_table_ids[count.index]
  destination_cidr_block    = "0.0.0.0/0"
  vpc_peering_connection_id = aws_vpc_peering_connection.external_to_internal.id
}
