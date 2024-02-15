# Application tier insatnce setup

resource "aws_lb" "application_tier" {
  name               = "application-tier-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.arch-sg.id]
  subnets            = [aws_subnet.arch-pub-sub-1.id, aws_subnet.arch-pub-sub-2.id]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "application_tier" {
  name     = "application-tier-lb-tg"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.arch-vpc.id
}

resource "aws_lb_listener" "application_tier" {
  load_balancer_arn = aws_lb.application_tier.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application_tier.arn
  }
}

# Create a launch template for application tier
resource "aws_launch_template" "application_tier" {
  name = "application_tier"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 8
    }
  }


  instance_type = var.instance-type
  image_id      = data.aws_ami.amazon_linux_2023.id
  key_name = "terra-keypair"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.arch-sg.id]
  }

    user_data = "${path.module}/shell-script/app-server.sh"

  depends_on = [
    aws_nat_gateway.nat-gw-1 , aws_nat_gateway.nat-gw-2

  ]
}

# Create autoscaling group for application tier
resource "aws_autoscaling_group" "application_tier" {
  name                      = "ASG-Application-Tier"
  max_size                  = var.max-size
  min_size                  = var.min-size
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = var.desired-size
  vpc_zone_identifier       = [aws_subnet.arch-pri-sub-1.id, aws_subnet.arch-pri-sub-2.id]

  launch_template {
    id      = aws_launch_template.application_tier.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.application_tier.arn]


#   lifecycle {
#     ignore_changes = [load_balancers, target_group_arns]
#   }

  tag {
    key                 = "Name"
    value               = "application_app"
    propagate_at_launch = true
  }
}