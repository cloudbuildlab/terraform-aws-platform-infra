module "network" {
  source = "../../modules/network"

  environment = "dev"
  name_prefix = "network"

  # VPC CIDRs
  external_vpc_cidr = "10.1.0.0/16"
  internal_vpc_cidr = "10.0.0.0/16"

  # Availability Zones
  availability_zones = ["ap-southeast-1a"]

  # External VPC Subnets
  external_public_subnet_cidrs  = ["10.1.1.0/24"]
  external_private_subnet_cidrs = ["10.1.11.0/24"]

  # Internal VPC Subnets
  internal_private_subnet_cidrs = ["10.0.11.0/24"]

  # Tags
  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# External VPC (for internet access)
module "external_vpc" {
  source  = "cloudbuildlab/vpc/aws"
  version = ">= 1.0.5"

  vpc_name = "dev-external-vpc"
  vpc_cidr = "10.1.0.0/16"

  availability_zones = ["ap-southeast-1a"]

  # Minimal subnet configuration
  public_subnet_cidrs = ["10.1.1.0/24"]

  # NAT Gateway configuration
  enable_nat_gateway = true
  nat_gateway_type   = "single"

  tags = {
    Environment = "dev"
    Network     = "external"
  }
}

# Internal VPC
module "internal_vpc" {
  source  = "cloudbuildlab/vpc/aws"
  version = ">= 1.0.5"

  vpc_name = "dev-internal-vpc"
  vpc_cidr = "10.0.0.0/16"

  availability_zones = ["ap-southeast-1a"]

  # Minimal subnet configuration
  private_subnet_cidrs = ["10.0.11.0/24"]

  # No NAT Gateway needed
  enable_nat_gateway = false

  tags = {
    Environment = "dev"
    Network     = "internal"
  }
}

# VPC Peering Connection
resource "aws_vpc_peering_connection" "external_to_internal" {
  vpc_id      = module.external_vpc.vpc_id
  peer_vpc_id = module.internal_vpc.vpc_id
  auto_accept = true

  tags = {
    Name        = "dev-external-to-internal"
    Environment = "dev"
  }
}

# Route table updates to route internet traffic through External VPC
resource "aws_route" "internal_to_external" {
  route_table_id            = module.internal_vpc.private_route_table_ids[0]
  destination_cidr_block    = "0.0.0.0/0"
  vpc_peering_connection_id = aws_vpc_peering_connection.external_to_internal.id
}
