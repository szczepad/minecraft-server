# Create network-infrastructure for server
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "${var.name}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_subnet" "sn" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = aws_vpc.vpc.cidr_block

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_route_table_association" "assoc" {
  subnet_id = aws_subnet.sn.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "sg" {
  name= "${var.name}"
  vpc_id = aws_vpc.vpc.id 

  ingress {
    description = "Connections via SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Connections to Minecraft"
    from_port = 25565
    to_port = 25565
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    description = "Allow Egress"
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create AMI, Server and IP

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "server" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "${var.instance_type}"
  subnet_id = aws_subnet.sn.id
  vpc_security_group_ids = [aws_security_group.sg.id]

  key_name = var.ssh_key_name

  root_block_device {
    volume_size = "25"
  }

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_eip" "eip" {
  instance = aws_instance.server.id
  vpc = true
}