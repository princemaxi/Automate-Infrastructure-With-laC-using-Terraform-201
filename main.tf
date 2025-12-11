provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public" {
  count                   = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index * 2)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  
  tags = merge(
    var.tags,
    {
      Name = format("public-subnet-%02d", count.index + 1)
      Tier = "public"
    }
  )
} 

resource "aws_subnet" "private" {
  count                   = var.preferred_number_of_private_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets
  vpc_id                  = aws_vpc.main.id
  availability_zone       = var.azs[floor(count.index / 2)]
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index * 2 + 1)
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name = format("private-subnet-%02d", count.index + 1)
      Tier = "private"
    }
  )
}

