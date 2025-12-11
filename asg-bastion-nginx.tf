###############################################
# SNS Topic for Auto Scaling Notifications
###############################################

resource "aws_sns_topic" "asg_notifications" {
  name = "default-autoscaling-topic"
}

resource "aws_autoscaling_notification" "asg_events" {
  group_names = [
    aws_autoscaling_group.bastion_asg.name,
    aws_autoscaling_group.nginx_asg.name,
    aws_autoscaling_group.wordpress_asg.name,
    aws_autoscaling_group.tooling_asg.name
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = aws_sns_topic.asg_notifications.arn
}

###############################################
# Random Shuffle for AZ distribution
###############################################

resource "random_shuffle" "az_list" {
  input = data.aws_availability_zones.available.names
}

###############################################
# Launch Template - Bastion
###############################################

resource "aws_launch_template" "bastion_lt" {
  name_prefix   = "bastion-lt-"
  image_id      = var.ami
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ip.id
  }

  key_name = var.keypair

  placement {
    availability_zone = random_shuffle.az_list.result[0]
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "bastion-instance" })
  }

  user_data = filebase64("${path.module}/bastion.sh")

  lifecycle {
    create_before_destroy = true
  }
}

###############################################
# Auto Scaling Group - Bastion
###############################################

resource "aws_autoscaling_group" "bastion_asg" {
  name                 = "bastion-asg"
  max_size             = 2
  min_size             = 1
  desired_capacity     = 1
  health_check_type    = "EC2"
  health_check_grace_period = 300

  vpc_zone_identifier = [
    aws_subnet.public[0].id,
    aws_subnet.public[1].id
  ]

  launch_template {
    id      = aws_launch_template.bastion_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "bastion-instance"
    propagate_at_launch = true
  }
}

###############################################
# Launch Template - Nginx
###############################################

resource "aws_launch_template" "nginx_lt" {
  name_prefix   = "nginx-lt-"
  image_id      = var.ami
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.nginx_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ip.id
  }

  key_name = var.keypair

  placement {
    availability_zone = random_shuffle.az_list.result[1]
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "nginx-instance" })
  }

  user_data = filebase64("${path.module}/nginx.sh")

  lifecycle {
    create_before_destroy = true
  }
}

###############################################
# Auto Scaling Group - Nginx
###############################################

resource "aws_autoscaling_group" "nginx_asg" {
  name                 = "nginx-asg"
  max_size             = 2
  min_size             = 1
  desired_capacity     = 1
  health_check_type    = "ELB"
  health_check_grace_period = 300

  vpc_zone_identifier = [
    aws_subnet.public[0].id,
    aws_subnet.public[1].id
  ]

  launch_template {
    id      = aws_launch_template.nginx_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "nginx-instance"
    propagate_at_launch = true
  }
}

###############################################
# Attach Nginx ASG to External ALB
###############################################

resource "aws_autoscaling_attachment" "nginx_attach" {
  autoscaling_group_name = aws_autoscaling_group.nginx_asg.id
  lb_target_group_arn = aws_lb_target_group.nginx_tgt.arn
}
