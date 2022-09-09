resource "aws_security_group" "security_group_sessions" {
  vpc_id      = aws_vpc.main.id
  name        = "SG-Sessions-Wordpress-Challenge"
  description = "SG-Sessions-Wordpress-Challenge"

  ingress {
    description      = "MEMCACHED"
    from_port        = 11211
    to_port          = 11211
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
    Name = "SG-Sessions-Wordpress-Challenge"
  }
}

resource "aws_elasticache_subnet_group" "ecsg" {
  name       = "ecsg-mysql"
  subnet_ids = [aws_subnet.priv-az-a.id, aws_subnet.priv-az-b.id]

  tags = {
    Name = "DBSG-Sessions-Wordpress-Challenge"
  }
}

resource "aws_elasticache_cluster" "elasticache" {
  cluster_id           = "cluster-sessions"
  engine               = "memcached"
  engine_version       = "1.6.6"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 2
  subnet_group_name   = aws_elasticache_subnet_group.ecsg.name

  preferred_availability_zones = ["us-east-1a", "us-east-1b"]

  tags = {
    Name = "Sessions-Wordpress-Challenge"
  }
}
