region                        = "eu-west-2"
vpc_cidr                      = "172.16.0.0/16"
enable_dns_support            = true
enable_dns_hostnames          = true
preferred_number_of_public_subnets = 2
preferred_number_of_private_subnets = 4

enable_classiclink              = false
enable_classiclink_dns_support = false

name = "production"

ami     = "ami-099400d52583dd8c4"
keypair = "devops"

# Replace this with your actual AWS account number
account_no = "686255973523"

master-username = "max"
master-password = "MaxStrongPassword123!"

tags = {
  Environment     = "production"
  Owner-Email     = "maxiprofresh@gmail.com"
  Managed-By      = "Terraform"
  Billing-Account = "686255973523"
}

