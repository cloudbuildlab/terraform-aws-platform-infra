############################################
# Provider Configuration
############################################

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

############################################
# VPC Module
############################################

module "network" {
  source = "../../modules/network"

  environment = "example"
  name_prefix = "complete"

  # VPC CIDRs
  external_vpc_cidr = "10.1.0.0/16"
  internal_vpc_cidr = "10.0.0.0/16"

  # Availability Zones
  availability_zones = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c", "ap-southeast-2-akl-1a"]

  # External VPC Subnets
  external_public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24"]
  external_private_subnet_cidrs = ["10.1.11.0/24", "10.1.12.0/24", "10.1.13.0/24", "10.1.14.0/24"]

  # Internal VPC Subnets
  internal_private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24", "10.0.14.0/24"]

  # Tags
  tags = {
    Environment = "example"
    ManagedBy   = "terraform"
  }
}

data "http" "my_public_ip" {
  url = "http://ifconfig.me/ip"
}

# Security Group for Test Instance
resource "aws_security_group" "test_instance" {
  name        = "test-instance-sg"
  description = "Security group for test instance"
  vpc_id      = module.network.internal_vpc_id

  ingress {
    description = "SSH from EC2 Instance Connect"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.http.my_public_ip.response_body}/32"] # In production, restrict this to your IP
  }

  # Allow ICMP from external VPC
  ingress {
    description = "ICMP from external VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.1.0.0/16"] # External VPC CIDR
  }

  # Allow ICMP to external VPC
  egress {
    description = "ICMP to external VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.1.0.0/16"] # External VPC CIDR
  }

  # Allow all other outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "test-instance-sg"
    Environment = "example"
  }
}

# Security Group for External VPC Test Instance
resource "aws_security_group" "external_test_instance" {
  name        = "external-test-instance-sg"
  description = "Security group for external test instance"
  vpc_id      = module.network.external_vpc_id

  ingress {
    description = "SSH from EC2 Instance Connect"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.http.my_public_ip.response_body}/32"] # In production, restrict this to your IP
  }

  # Allow ICMP from internal VPC
  ingress {
    description = "ICMP from internal VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/16"] # Internal VPC CIDR
  }

  # Allow ICMP from public subnet
  ingress {
    description = "ICMP from public subnet"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.1.1.0/24"] # Public subnet CIDR
  }

  # Allow ICMP to internal VPC
  egress {
    description = "ICMP to internal VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/16"] # Internal VPC CIDR
  }

  # Allow ICMP to public subnet
  egress {
    description = "ICMP to public subnet"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.1.1.0/24"] # Public subnet CIDR
  }

  # Allow all other outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "external-test-instance-sg"
    Environment = "example"
  }
}

# EC2 Instance Connect Endpoint for Internal VPC
resource "aws_ec2_instance_connect_endpoint" "internal_test" {
  subnet_id          = module.network.internal_private_subnet_ids[0]
  security_group_ids = [aws_security_group.test_instance.id]

  tags = {
    Name        = "internal-test-instance-connect"
    Environment = "example"
  }
}

# EC2 Instance Connect Endpoint for External VPC
resource "aws_ec2_instance_connect_endpoint" "external_test" {
  subnet_id          = module.network.external_private_subnet_ids[0]
  security_group_ids = [aws_security_group.external_test_instance.id]

  tags = {
    Name        = "external-test-instance-connect"
    Environment = "example"
  }
}

# Test instance in internal VPC
resource "aws_instance" "test" {
  ami                    = "ami-0f6a1a6507c55c9a8" # Amazon Linux 2023
  instance_type          = "t3.micro"
  subnet_id              = module.network.internal_private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.test_instance.id]

  tags = merge(var.tags, {
    Name = "test-instance"
  })
}

# Test instance in external VPC private subnet
resource "aws_instance" "external_test" {
  ami                    = "ami-0f6a1a6507c55c9a8" # Amazon Linux 2023
  instance_type          = "t3.micro"
  subnet_id              = module.network.external_private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.external_test_instance.id]

  tags = merge(var.tags, {
    Name = "external-test-instance"
  })
}

# Security Group for External VPC Public Test Instance
resource "aws_security_group" "external_public_test_instance" {
  name        = "external-public-test-instance-sg"
  description = "Security group for external public test instance"
  vpc_id      = module.network.external_vpc_id

  # Allow SSH from your IP
  ingress {
    description = "SSH from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.http.my_public_ip.response_body}/32"]
  }

  # Allow ICMP from private subnet
  ingress {
    description = "ICMP from private subnet"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.1.11.0/24"] # Private subnet CIDR
  }

  # Allow ICMP to private subnet
  egress {
    description = "ICMP to private subnet"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.1.11.0/24"] # Private subnet CIDR
  }

  # Allow all other outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "external-public-test-instance-sg"
    Environment = "example"
  }
}

# Test instance in external VPC public subnet
resource "aws_instance" "external_public_test" {
  ami                         = "ami-0f6a1a6507c55c9a8" # Amazon Linux 2023
  instance_type               = "t3.micro"
  subnet_id                   = module.network.external_public_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.external_public_test_instance.id]
  associate_public_ip_address = true # This ensures the instance gets a public IP

  tags = merge(var.tags, {
    Name = "external-public-test-instance"
  })
}

# Output VPC and subnet IDs for debugging
output "external_vpc_id" {
  description = "ID of the external VPC"
  value       = module.network.external_vpc_id
}

output "external_public_subnet_ids" {
  description = "IDs of the external VPC public subnets"
  value       = module.network.external_public_subnet_ids
}

output "external_private_subnet_ids" {
  description = "IDs of the external VPC private subnets"
  value       = module.network.external_private_subnet_ids
}

output "vpc_peering_connection_id" {
  description = "ID of the VPC peering connection"
  value       = module.network.vpc_peering_connection_id
}
