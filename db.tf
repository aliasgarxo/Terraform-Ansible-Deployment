resource "aws_db_instance" "app_db" {
  allocated_storage    = 20 
  db_name              = var.db_name
  engine               = "mysql" 
  engine_version       = "8.0"
  instance_class       = var.db_instance_class
  username             = var.db_username
  password             = var.db_password 
  skip_final_snapshot  = true  
  vpc_security_group_ids = [var.security_group_id] 
  db_subnet_group_name = aws_db_subnet_group.app_db_subnet_group.name 
}

resource "aws_db_subnet_group" "app_db_subnet_group" {
  name       = "application-db-subnet-group"
  subnet_ids = [aws_subnet.arch-pri-sub-1.id, aws_subnet.arch-pri-sub-2.id]
}

output "db_endpoint" {
  value = aws_db_instance.app_db.address 
}
