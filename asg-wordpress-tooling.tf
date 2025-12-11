###############################################
# Launch Template - WordPress
###############################################

resource "aws_launch_template" "wordpress_lt" {
  name_prefix   = "wordpress-lt-"
  image_id      = var.ami
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.webserver_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ip.id
  }

  key_name = var.keypair

  placement {
    availability_zone = random_shuffle.az_list.result[0]
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "wordpress-instance" })
  }

  user_data = filebase64("${path.module}/wordpress.sh")

  lifecycle {
    create_before_destroy = true
  }
}

###############################################
# Auto Scaling Group - WordPress
###############################################

resource "aws_autoscaling_group" "wordpress_asg" {
  name                 = "wordpress-asg"
  max_size             = 2
  min_size             = 1
  desired_capacity     = 1
  health_check_type    = "ELB"
  health_check_grace_period = 300

  vpc_zone_identifier = [
    aws_subnet.private[0].id,
    aws_subnet.private[1].id
  ]

  launch_template {
    id      = aws_launch_template.wordpress_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "wordpress-instance"
    propagate_at_launch = true
  }
}

###############################################
# Attach WordPress ASG to Internal ALB
###############################################

resource "aws_autoscaling_attachment" "wordpress_attach" {
  autoscaling_group_name = aws_autoscaling_group.wordpress_asg.id
  lb_target_group_arn = aws_lb_target_group.wordpress_tgt.arn
}

###############################################
# Launch Template - Tooling
###############################################

resource "aws_launch_template" "tooling_lt" {
  name_prefix   = "tooling-lt-"
  image_id      = var.ami
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.webserver_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ip.id
  }

  key_name = var.keypair

  placement {
    availability_zone = random_shuffle.az_list.result[1]
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "tooling-instance" })
  }

  user_data = filebase64("${path.module}/tooling.sh")

  lifecycle {
    create_before_destroy = true
  }
}

###############################################
# Auto Scaling Group - Tooling
###############################################

resource "aws_autoscaling_group" "tooling_asg" {
  name                 = "tooling-asg"
  max_size             = 2
  min_size             = 1
  desired_capacity     = 1
  health_check_type    = "ELB"
  health_check_grace_period = 300

  vpc_zone_identifier = [
    aws_subnet.private[0].id,
    aws_subnet.private[1].id
  ]

  launch_template {
    id      = aws_launch_template.tooling_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "tooling-instance"
    propagate_at_launch = true
  }
}

###############################################
# Attach Tooling ASG to Internal ALB
###############################################

resource "aws_autoscaling_attachment" "tooling_attach" {
  autoscaling_group_name = aws_autoscaling_group.tooling_asg.id
  lb_target_group_arn = aws_lb_target_group.tooling_tgt.arn
}
