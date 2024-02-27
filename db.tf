resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.arch-vpc.id

  # Allow incoming MySQL traffic from the application server
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "app_db" {
  allocated_storage    = 20 
  db_name              = var.db_name
  engine               = "mysql" 
  engine_version       = "8.0"
  instance_class       = var.db_instance_class
  username             = var.db_username
  password             = var.db_password 
  skip_final_snapshot  = true  
  vpc_security_group_ids = [aws_security_group.rds_sg.id] 
  db_subnet_group_name = aws_db_subnet_group.app_db_subnet_group.name 
}

resource "aws_db_subnet_group" "app_db_subnet_group" {
  name       = "application-db-subnet-group"
  subnet_ids = [aws_subnet.arch-pri-sub-1.id, aws_subnet.arch-pri-sub-2.id]
}

output "db_endpoint" {
  value = aws_db_instance.app_db.endpoint 
}
