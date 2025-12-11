variable "region" {
  type        = string
  description = "The region to deploy resources"
  default     = "eu-west-2"
}

variable "azs" {
  type    = list(string)
  default = ["eu-west-2a", "eu-west-2b"]
}

variable "vpc_cidr" {
  type        = string
  description = "The VPC CIDR block"
  default     = "172.16.0.0/16"
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "enable_classiclink" {
  type = bool
}

variable "enable_classiclink_dns_support" {
  type = bool
}

variable "preferred_number_of_public_subnets" {
  type        = number
  description = "Number of public subnets"
  default     = 2
}

variable "preferred_number_of_private_subnets" {
  type        = number
  description = "Number of private subnets"
  default     = 4
}

variable "name" {
  type        = string
  description = "The name of the project or environment"
  default     = "production"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

variable "ami" {
  type        = string
  description = "AMI ID for the launch template"
}

variable "keypair" {
  type        = string
  description = "Key pair for the EC2 instances"
}

variable "account_no" {
  type        = string
  description = "The AWS account number"
}

variable "master-username" {
  type        = string
  description = "RDS admin username"
}

variable "master-password" {
  type        = string
  description = "RDS master password"
}
