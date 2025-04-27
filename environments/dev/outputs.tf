output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.platform_infra.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.platform_infra.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.platform_infra.private_subnet_ids
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.platform_infra.nat_gateway_ids
} 