variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "vpc"
}

variable "external_vpc_cidr" {
  description = "CIDR block for the external VPC"
  type        = string
}

variable "internal_vpc_cidr" {
  description = "CIDR block for the internal VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "external_public_subnet_cidrs" {
  description = "CIDR blocks for external VPC public subnets"
  type        = list(string)
}

variable "external_private_subnet_cidrs" {
  description = "CIDR blocks for external VPC private subnets"
  type        = list(string)
}

variable "internal_private_subnet_cidrs" {
  description = "CIDR blocks for internal VPC private subnets"
  type        = list(string)
}

variable "nat_gateway_type" {
  description = "Type of NAT Gateway (single or one_per_az)"
  type        = string
  default     = "single"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
