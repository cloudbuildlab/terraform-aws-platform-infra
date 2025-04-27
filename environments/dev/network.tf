module "network" {
  source = "../../modules/network"

  environment = "dev"
  name_prefix = "network"

  # VPC CIDRs
  external_vpc_cidr = "10.1.0.0/16"
  internal_vpc_cidr = "10.0.0.0/16"

  # Availability Zones
  availability_zones = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]

  # External VPC Subnets
  external_public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
  external_private_subnet_cidrs = ["10.1.11.0/24", "10.1.12.0/24"]

  # Internal VPC Subnets
  internal_private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  # Tags
  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# VPC Peering Connection
resource "aws_vpc_peering_connection" "external_to_internal" {
  vpc_id      = module.network.external_vpc_id
  peer_vpc_id = module.network.internal_vpc_id
  auto_accept = true

  tags = {
    Name        = "dev-external-to-internal"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# Route table updates to route internet traffic through External VPC
resource "aws_route" "internal_to_external" {
  count                     = length(module.network.internal_private_route_table_ids)
  route_table_id            = module.network.internal_private_route_table_ids[count.index]
  destination_cidr_block    = "0.0.0.0/0"
  vpc_peering_connection_id = aws_vpc_peering_connection.external_to_internal.id
}
