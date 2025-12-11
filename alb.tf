###############################################
# External Public Application Load Balancer
###############################################

resource "aws_lb" "ext_alb" {
  name               = "ext-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ext_alb_sg.id]
  subnets            = [
    aws_subnet.public[0].id,
    aws_subnet.public[1].id
  ]

  ip_address_type = "ipv4"

  tags = merge(var.tags, { Name = "ACS-ext-alb" })
}

###############################################
# External ALB Target Group (HTTP)
###############################################

resource "aws_lb_target_group" "nginx_tgt" {
  name        = "nginx-tgt"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/healthstatus"
    protocol            = "HTTP"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, { Name = "nginx-tgt" })
}

###############################################
# External ALB Listener (NO CERTIFICATES)
###############################################

resource "aws_lb_listener" "nginx_listener" {
  load_balancer_arn = aws_lb.ext_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tgt.arn
  }
}

###############################################
# Internal ALB (Private)
###############################################

resource "aws_lb" "int_alb" {
  name               = "int-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.int_alb_sg.id]

  subnets = [
    aws_subnet.private[0].id,
    aws_subnet.private[2].id
  ]

  ip_address_type = "ipv4"

  tags = merge(var.tags, { Name = "ACS-int-alb" })
}

###############################################
# WordPress Target Group (HTTP)
###############################################

resource "aws_lb_target_group" "wordpress_tgt" {
  name        = "wordpress-tgt"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/healthstatus"
    protocol            = "HTTP"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

###############################################
# Tooling Target Group (HTTP)
###############################################

resource "aws_lb_target_group" "tooling_tgt" {
  name        = "tooling-tgt"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/healthstatus"
    protocol            = "HTTP"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

###############################################
# Internal ALB Listener (HTTP ONLY)
###############################################

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.int_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_tgt.arn
  }
}

###############################################
# Listener Rule for tooling (NO DOMAIN)
###############################################

# We route based on PATH, not host header
# because NO DOMAIN EXISTS

resource "aws_lb_listener_rule" "tooling" {
  listener_arn = aws_lb_listener.web_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tooling_tgt.arn
  }

  condition {
    path_pattern {
      values = ["*/tooling*"]
    }
  }
}
