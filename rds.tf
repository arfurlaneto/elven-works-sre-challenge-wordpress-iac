resource "aws_security_group" "security_group_db" {
  vpc_id      = aws_vpc.main.id
  name        = "SG-DB-Wordpress-Challenge"
  description = "SG-DB-Wordpress-Challenge"

  ingress {
    description      = "MYSQL"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [aws_security_group.security_group_web.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "SG-DB-Wordpress-Challenge"
  }
}

resource "aws_db_subnet_group" "dbsg" {
  name       = "dbsg-mysql"
  subnet_ids = [aws_subnet.priv-az-a.id, aws_subnet.priv-az-b.id]

  tags = {
    Name = "DBSG-DB-Wordpress-Challenge"
  }
}

resource "aws_db_instance" "db" {
  engine                 = "mysql"
  engine_version         = "5.7.37"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = var.db_user
  password               = var.db_password
  name                   = "wordpress"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.security_group_db.id]
  db_subnet_group_name   = aws_db_subnet_group.dbsg.name
  availability_zone      = "us-east-1a"
  #multi_az = true

  tags = {
    Name = "DB-Wordpress-Challenge"
  }
}
