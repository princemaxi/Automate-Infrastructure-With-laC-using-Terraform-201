###############################################
# Elastic IP for NAT Gateway (single EIP)
###############################################
resource "aws_eip" "nat_eip" {
  depends_on = [
    aws_internet_gateway.ig
  ]

  tags = merge(
    var.tags,
    {
      Name = format("%s-eip", var.name)
    }
  )
}

###############################################
# NAT Gateway (single NAT)
###############################################
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id  # choose the first public subnet

  depends_on = [
    aws_internet_gateway.ig
  ]

  tags = merge(
    var.tags,
    {
      Name = format("%s-nat", var.name)
    }
  )
}
