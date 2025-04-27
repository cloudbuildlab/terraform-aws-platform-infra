output "external_vpc_id" {
  description = "ID of the external VPC"
  value       = module.external_vpc.vpc_id
}

output "internal_vpc_id" {
  description = "ID of the internal VPC"
  value       = module.internal_vpc.vpc_id
}

output "external_public_subnet_ids" {
  description = "IDs of the external VPC public subnets"
  value       = module.external_vpc.public_subnet_ids
}

output "external_private_subnet_ids" {
  description = "IDs of the external VPC private subnets"
  value       = module.external_vpc.private_subnet_ids
}

output "internal_private_subnet_ids" {
  description = "IDs of the internal VPC private subnets"
  value       = module.internal_vpc.private_subnet_ids
}

output "internal_private_route_table_ids" {
  description = "IDs of the internal VPC private route tables"
  value       = module.internal_vpc.private_route_table_ids
}

output "vpc_peering_connection_id" {
  description = "ID of the VPC peering connection"
  value       = aws_vpc_peering_connection.external_to_internal.id
}
