
resource "aws_vpc" "main" {
  cidr_block       = var.VPC_CIDR_BLOCK
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.PUBLIC_SUBNET_CIDR_BLOCK
  map_public_ip_on_launch = true
  availability_zone = var.PUBLIC_SUBNET_AZ

  tags = {
    Name = "Public Subnet"
  }
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.PRIVATE_SUBNET_CIDR_BLOCK
  availability_zone = var.PRIVATE_SUBNET_AZ
  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


resource "aws_eip" "nat" {
  vpc              = true
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "private"
	  }
}


resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}


resource "aws_security_group" "instance" {
     name = "terrafrom-example-instance"
     vpc_id = aws_vpc.main.id
     ingress {
     from_port = "0"
     to_port   = "0"
     protocol  = "-1"
     cidr_blocks = ["0.0.0.0/0"]
     }
     egress {
     from_port = "0"
     to_port   = "0"
     protocol  = "-1"
     cidr_blocks = ["0.0.0.0/0"]
 }
}
