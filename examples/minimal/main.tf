module "network" {
  source = "../../modules/network"

  environment = "example"
  name_prefix = "minimal"

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
    Environment = "example"
    ManagedBy   = "terraform"
  }
}

module "security_groups" {
  source = "../../modules/security-groups"

  vpc_id   = "vpc-12345678" # Replace with actual VPC ID
  vpc_name = "minimal-vpc"

  tags = {
    Environment = "minimal"
    ManagedBy   = "terraform"
  }
}
