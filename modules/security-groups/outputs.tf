output "default_sg_id" {
  description = "The ID of the default security group"
  value       = aws_security_group.default.id
}

output "bastion_sg_id" {
  description = "The ID of the bastion security group"
  value       = aws_security_group.bastion.id
}
