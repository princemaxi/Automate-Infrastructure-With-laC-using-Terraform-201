##########################################
# External ALB Security Group
##########################################
resource "aws_security_group" "ext_alb_sg" {
  name        = "ext-alb-sg"
  description = "Allow HTTP from anywhere"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "ext-alb-sg" })
}

##########################################
# Bastion Security Group
##########################################
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH from anywhere"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "bastion-sg" })
}

##########################################
# Nginx Security Group
##########################################
resource "aws_security_group" "nginx_sg" {
  name        = "nginx-sg"
  description = "Allow traffic from ALB and Bastion"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "nginx-sg" })
}

resource "aws_security_group_rule" "nginx_http_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.nginx_sg.id
  source_security_group_id = aws_security_group.ext_alb_sg.id
}

resource "aws_security_group_rule" "nginx_ssh_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.nginx_sg.id
  source_security_group_id = aws_security_group.bastion_sg.id
}

##########################################
# Internal ALB Security Group
##########################################
resource "aws_security_group" "int_alb_sg" {
  name        = "int-alb-sg"
  description = "Allow traffic only from Nginx"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "int-alb-sg" })
}

resource "aws_security_group_rule" "int_alb_http_from_nginx" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.int_alb_sg.id
  source_security_group_id = aws_security_group.nginx_sg.id
}

##########################################
# Webserver Security Group
##########################################
resource "aws_security_group" "webserver_sg" {
  name        = "webserver-sg"
  description = "Allow traffic from internal ALB and Bastion"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "webserver-sg" })
}

resource "aws_security_group_rule" "web_http_from_int_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.webserver_sg.id
  source_security_group_id = aws_security_group.int_alb_sg.id
}

resource "aws_security_group_rule" "web_ssh_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.webserver_sg.id
  source_security_group_id = aws_security_group.bastion_sg.id
}

##########################################
# Datalayer Security Group
##########################################
resource "aws_security_group" "datalayer_sg" {
  name        = "datalayer-sg"
  description = "Allow traffic from webservers and Bastion"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "datalayer-sg" })
}

resource "aws_security_group_rule" "datalayer_nfs_from_web" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.datalayer_sg.id
  source_security_group_id = aws_security_group.webserver_sg.id
}

resource "aws_security_group_rule" "datalayer_mysql_from_bastion" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.datalayer_sg.id
  source_security_group_id = aws_security_group.bastion_sg.id
}

resource "aws_security_group_rule" "datalayer_mysql_from_web" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.datalayer_sg.id
  source_security_group_id = aws_security_group.webserver_sg.id
}
