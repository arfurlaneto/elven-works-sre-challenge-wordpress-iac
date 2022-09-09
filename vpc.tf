resource "aws_vpc" "main" {
  cidr_block = "10.99.0.0/16"

  tags = {
    Name = "VPC-Wordpress-Challenge"
  }
}

resource "aws_subnet" "pub-az-a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.99.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Pub-AZ-A"
  }
}

resource "aws_subnet" "pub-az-b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.99.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Pub-AZ-B"
  }
}

resource "aws_subnet" "priv-az-a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.99.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Priv-AZ-A"
  }
}

resource "aws_subnet" "priv-az-b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.99.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Priv-AZ-B"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Internet-Gateway-Wordpress-Challenge"
  }
}

resource "aws_eip" "eip" {
  vpc = true

  depends_on = [aws_internet_gateway.ig]
}

resource "aws_nat_gateway" "ng" {
  allocation_id     = aws_eip.eip.id
  subnet_id         = aws_subnet.pub-az-a.id
  connectivity_type = "public"

  tags = {
    Name = "Nat-Gateway-Wordpress-Challenge"
  }

  depends_on = [aws_internet_gateway.ig]
}

resource "aws_default_route_table" "public_routes" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    Name = "Public-Routes-Wordpress-Challenge"
  }
}

resource "aws_route_table" "private_routes" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.ng.id
  }

  tags = {
    Name = "Private-Routes-Wordpress-Challenge"
  }
}

resource "aws_route_table_association" "rta_public_a" {
  subnet_id      = aws_subnet.pub-az-a.id
  route_table_id = aws_default_route_table.public_routes.id
}

resource "aws_route_table_association" "rta_public_b" {
  subnet_id      = aws_subnet.pub-az-b.id
  route_table_id = aws_default_route_table.public_routes.id
}

resource "aws_route_table_association" "rta_private_a" {
  subnet_id      = aws_subnet.priv-az-a.id
  route_table_id = aws_route_table.private_routes.id
}

resource "aws_route_table_association" "rta_private_b" {
  subnet_id      = aws_subnet.priv-az-b.id
  route_table_id = aws_route_table.private_routes.id
}
