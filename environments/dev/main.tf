module "platform_infra" {
  source  = "cloudbuildlab/vpc/aws"
  version = ">= 1.0.5" # Flexible version for development

  vpc_name           = "dev-vpc"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["ap-southeast-2a", "ap-southeast-2b"] # Two AZs for dev

  # Subnet Configuration
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

  # NAT Gateway Configuration
  enable_nat_gateway = true

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
