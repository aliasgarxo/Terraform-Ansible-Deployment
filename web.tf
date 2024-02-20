# Create a load balancer, listener, and target group for web-server tier

resource "aws_lb" "front_end" {
  name               = "front-end-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.arch-sg.id]
  subnets            = [aws_subnet.arch-pub-sub-1.id, aws_subnet.arch-pub-sub-2.id]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "front_end" {
  name     = "front-end-lb-tg"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.arch-vpc.id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}

# Create a launch template for web-server tier
resource "aws_launch_template" "presentation_tier" {
  name = "presentation_tier"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 8
    }
  }
  
  user_data = "${base64encode(data.template_file.userdata.rendered)}"
  instance_type = var.instance-type
  image_id      = data.aws_ami.amazon_linux_2023.id
  key_name = "terra-keypair"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.arch-sg.id]
  }


  depends_on = [
    aws_lb.application_tier
  ]
}


# Create autoscaling group for presentation tier
resource "aws_autoscaling_group" "presentation_tier" {
  name                      = "ASG-Presentation-Tier"
  max_size                  = var.max-size
  min_size                  = var.min-size
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = var.desired-size
  vpc_zone_identifier       = [aws_subnet.arch-pub-sub-1.id, aws_subnet.arch-pub-sub-2.id]

  launch_template {
    id      = aws_launch_template.presentation_tier.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.front_end.arn]

#   lifecycle {
#     ignore_changes = [load_balancers, target_group_arns]
#   }

  tag {
    key                 = "Name"
    value               = "web"
    propagate_at_launch = true
  }
}