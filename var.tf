variable "region" {
  default = "us-east-2"
}

variable "vpc-name" {
  default = "dellhoak"
}
variable "cidr-block" {
  default = "69.69.0.0/16"
}


variable "instance-type" {
  default = "t2.micro"
}

#autosacling config
variable "max-size" {
  default = "4"
}
variable "min-size" {
  default = "2"
}
variable "desired-size" {
  default = "2"
}

#get the ami of amazon linux 2023 using data source
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.3.20240205.2-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

variable "db_name" {
  default = "userdata"
}
variable "db_instance_class" {
  default = "t2.micro"
}
variable "db_username" {
  default = "dell-user"
}
variable "db_password" {
  default = "Dellhoak@987"
}
variable "security_group_id" {
  default = "[aws_security_group.arch-sg.id]"
}
# variable "subnet_ids" {
#   type = list(string)
#   default = [aws_subnet.arch-pri-sub-1.id, aws_subnet.arch-pri-sub-2.id]
  
# } 