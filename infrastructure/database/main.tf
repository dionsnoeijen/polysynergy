resource "aws_security_group" "bastion_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["31.201.60.26/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Bastion Security Group"
  }
}

resource "aws_security_group" "db_sg" {
  vpc_id = var.vpc_id
  tags = {
    Name = "Database Security Group"
  }
}

resource "aws_security_group_rule" "allow_ecs_to_db" {
  security_group_id = aws_security_group.db_sg.id
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  source_security_group_id = var.ecs_sg_id
}

resource "aws_security_group_rule" "allow_bastion_to_db" {
  security_group_id = aws_security_group.db_sg.id
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
}

resource "aws_instance" "bastion" {
  ami           = "ami-04a5bacc58328233d"  # Ubuntu 22.04 LTS in eu-central-1
  instance_type = "t2.micro"
  subnet_id     = var.subnet1_id
  security_groups = [aws_security_group.bastion_sg.id]
  key_name      = var.ssh_key_name

  tags = {
    Name = "Bastion Host"
  }
}

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
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
}