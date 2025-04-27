output "internal_test_instance_id" {
  description = "ID of the test instance in internal VPC"
  value       = aws_instance.test.id
}

output "internal_test_instance_private_ip" {
  description = "Private IP of the test instance in internal VPC"
  value       = aws_instance.test.private_ip
}

output "internal_instance_connect_endpoint_id" {
  description = "ID of the EC2 Instance Connect endpoint in internal VPC"
  value       = aws_ec2_instance_connect_endpoint.internal_test.id
}

output "internal_instance_connect_endpoint_dns_name" {
  description = "DNS name of the EC2 Instance Connect endpoint in internal VPC"
  value       = aws_ec2_instance_connect_endpoint.internal_test.dns_name
}

output "external_test_instance_id" {
  description = "ID of the test instance in external VPC"
  value       = aws_instance.external_test.id
}

output "external_test_instance_private_ip" {
  description = "Private IP of the test instance in external VPC"
  value       = aws_instance.external_test.private_ip
}

output "external_instance_connect_endpoint_id" {
  description = "ID of the EC2 Instance Connect endpoint in external VPC"
  value       = aws_ec2_instance_connect_endpoint.external_test.id
}

output "external_instance_connect_endpoint_dns_name" {
  description = "DNS name of the EC2 Instance Connect endpoint in external VPC"
  value       = aws_ec2_instance_connect_endpoint.external_test.dns_name
}

output "external_public_test_instance_id" {
  description = "ID of the test instance in external VPC public subnet"
  value       = aws_instance.external_public_test.id
}

output "external_public_test_instance_private_ip" {
  description = "Private IP of the test instance in external VPC public subnet"
  value       = aws_instance.external_public_test.private_ip
}

output "external_public_test_instance_public_ip" {
  description = "Public IP of the test instance in external VPC public subnet"
  value       = aws_instance.external_public_test.public_ip
}
