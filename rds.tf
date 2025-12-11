# Subnet Group
resource "aws_db_subnet_group" "acs_rds" {
  name       = "acs-rds"
  subnet_ids = [
    aws_subnet.private[0].id,
    aws_subnet.private[2].id
  ]

  tags = merge(
    var.tags,
    { Name = "ACS-rds" }
  )
}

# RDS Instance
resource "aws_db_instance" "acs_rds" {
  allocated_storage      = 20
  storage_type           = "gp2"

  engine                 = "mysql"
  engine_version         = "5.7"

  instance_class = "db.t3.small"

  db_name                = "maxidb"
  username               = var.master-username
  password               = var.master-password

  parameter_group_name   = "default.mysql5.7"

  db_subnet_group_name   = aws_db_subnet_group.acs_rds.name
  vpc_security_group_ids = [aws_security_group.datalayer_sg.id]

  multi_az               = true
  skip_final_snapshot    = true
}
