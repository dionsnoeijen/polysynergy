resource "aws_db_subnet_group" "default" {
  name       = "rds-subnet-group"
  subnet_ids = [var.subnet1_id, var.subnet2_id]
  tags = {
    Name = "RDS subnet group"
  }
}

resource "aws_db_instance" "postgres" {
  engine                 = "postgres"
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  username               = var.db_username
  password               = var.db_password
  db_name                = var.db_name
  publicly_accessible    = false
  skip_final_snapshot    = true
  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.default.name
}
