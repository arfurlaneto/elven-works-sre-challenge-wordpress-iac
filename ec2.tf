resource "aws_security_group" "security_group_web" {
  name        = "SG-Web-Wordpress-Challenge"
  description = "SG-Web-Wordpress-Challenge"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "SG-Web-Wordpress-Challenge"
  }
}

resource "aws_instance" "web" {
  ami                         = "ami-08d4ac5b634553e16"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.pub-az-a.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.security_group_web.id]
  key_name                    = var.key_name

  tags = {
    Name = "Instance-Wordpress-Challenge"
  }

  provisioner "remote-exec" {
    inline = ["echo 'Waiting'"]

    connection {
      host = aws_instance.web.public_ip
      type = "ssh"
      user = "ubuntu"
      private_key = file(var.private_key_path)
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${aws_instance.web.public_ip}, --private-key ${var.private_key_path} wordpress.yml --extra-vars '{\"db_host\": \"${aws_db_instance.db.address}\", \"db_user\": \"${var.db_user}\", \"db_password\": \"${var.db_password}\", \"memcached_endpoint\": \"${aws_elasticache_cluster.elasticache.configuration_endpoint}\"}'"
  }
}
