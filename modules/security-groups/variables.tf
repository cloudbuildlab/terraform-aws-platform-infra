variable "vpc_id" {
  description = "The VPC ID where security groups will be created"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC for naming security groups"
  type        = string
}

variable "bastion_ingress_cidr_blocks" {
  description = "List of CIDR blocks allowed to access bastion hosts"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Restrict this in production!
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
