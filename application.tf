# Application tier insatnce setup

resource "aws_lb" "application_tier" {
  name               = "application-tier-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.arch-sg.id]
  subnets            = [aws_subnet.arch-pub-sub-1.id, aws_subnet.arch-pub-sub-2.id]

  enable_deletion_protection = false
  
}

resource "aws_lb_target_group" "application_tier" {
  name     = "application-tier-lb-tg"
  port     = "8080"
  protocol = "HTTP"
  vpc_id   = aws_vpc.arch-vpc.id
}

resource "aws_lb_listener" "application_tier" {
  load_balancer_arn = aws_lb.application_tier.arn
  port              = "8080"
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
  key_name      = aws_key_pair.terra-keypair.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.arch-sg.id]
  }

  user_data = "${base64encode(data.template_file.userdata.rendered)}"
  #user_data = file("${path.module}/shell-script/app-server.sh")

  depends_on = [
    aws_nat_gateway.nat-gw-1, aws_nat_gateway.nat-gw-2

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
    value               = "app"
    propagate_at_launch = true
  }
}

resource "aws_instance" "jump-ec2" {
  ami = data.aws_ami.amazon_linux_2023.id
  subnet_id = aws_subnet.arch-pub-sub-1.id
  key_name = aws_key_pair.terra-keypair.key_name
  associate_public_ip_address = true
  security_groups = [aws_security_group.arch-sg.id]
  instance_type = var.instance-type
  iam_instance_profile = aws_iam_instance_profile.ansible.name
  user_data = file("${path.module}/shell-script/bastion.sh")
  depends_on = [ local_file.private_key_pem , aws_iam_role.ansible_role, aws_autoscaling_group.application_tier, aws_autoscaling_group.presentation_tier]

  provisioner "file" {
    source      = "terra-keypair.pem" 
    destination = "/tmp/ssh-key-2024-02-19.key" 
    connection {
      type        = "ssh"
      user        = "ec2-user" 
      private_key = tls_private_key.pri-terra-key.private_key_pem 
      host        = self.public_ip 
    }
  }
  provisioner "file" {
    source      = "${path.module}/shell-script/get-hosts.sh"
    destination = "/home/ec2-user/get-hosts.sh"
    connection {
      type        = "ssh"
      user        = "ec2-user" 
      private_key = tls_private_key.pri-terra-key.private_key_pem 
      host        = self.public_ip 
    }
  }
  provisioner "file" {
    source      = "${path.module}/shell-script/get-hosts-web.sh"
    destination = "/home/ec2-user/get-hosts-web.sh"
    connection {
      type        = "ssh"
      user        = "ec2-user" 
      private_key = tls_private_key.pri-terra-key.private_key_pem 
      host        = self.public_ip 
    }
  }
  provisioner "remote-exec" {
    inline = [
      "mv /tmp/ssh-key-2024-02-19.key /home/ec2-user/terra-keypair.pem",
      "chmod 400 /home/ec2-user/terra-keypair.pem",
      "chmod +x /home/ec2-user/get-hosts.sh",
      "chmod +x /home/ec2-user/get-hosts-web.sh",
      "echo 'Provisioner script completed' > /home/ec2-user/provisioner_done.txt"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user" 
      private_key = tls_private_key.pri-terra-key.private_key_pem 
      host        = self.public_ip 
    }
  }

  tags = {
    Name = "Bastion-Host"
  }

}
output "instance_ip" {
  value = aws_instance.jump-ec2.public_ip
  description = "The public IP of the instance"
}

