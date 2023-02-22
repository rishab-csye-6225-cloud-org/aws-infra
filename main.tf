resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.assignment}-vpc"
  }
}


data "aws_availability_zones" "available" {
  state = var.state
}

//public subnet
resource "aws_subnet" "subnet_public" {
  vpc_id = aws_vpc.main.id

  count      = length(var.public_subnet_cidr_list)
  cidr_block = var.public_subnet_cidr_list[count.index]
  // cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 1)
  //availability_zone       = data.aws_availability_zones.available.names[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]

  map_public_ip_on_launch = var.map_public_ip


  tags = {
    Name = "${var.assignment} - Public Subnet - ${count.index + 1}"
  }
}


//private subnet
resource "aws_subnet" "subnet_private" {
  vpc_id = aws_vpc.main.id
  count  = length(var.private_subnet_cidr_list)
  //cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 4)

  cidr_block = var.private_subnet_cidr_list[count.index]
  //availability_zone = data.aws_availability_zones.available.names[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]


  tags = {
    Name = "${var.assignment} - Private Subnet - ${count.index + 1}"
  }
}

//internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.assignment} - internet gateway"
  }
}


//public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.internet_gateway_cidr
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.assignment} - public route table"
  }
}


//public subnet association
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.public_subnet_cidr_list)
  subnet_id      = aws_subnet.subnet_public[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

//private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.assignment} - private route table"
  }
}


//private subnet association
resource "aws_route_table_association" "private_subnet_association" {
  count = length(var.private_subnet_cidr_list)

  subnet_id      = aws_subnet.subnet_private[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

//security group for ec2 instance
resource "aws_security_group" "application_security_group" {
  name        = "application security group"
  description = "Allow TCP protocol inbound/ingress traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TCP traffic to port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TCP traffic to port 80"
    to_port     = 80
    from_port   = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TCP traffic to port 22"
    to_port     = 22
    from_port   = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TCP traffic to port anywhere"
    to_port     = var.app_port
    from_port   = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.assignment} - application security group"
  }
}


//ec2 instance
resource "aws_instance" "web" {
  ami                         = var.ami_image_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = var.ssh_key_name

  subnet_id = aws_subnet.subnet_public[0].id //giving a public subnet Id

  disable_api_termination = false
  root_block_device {
    delete_on_termination = true
    volume_size           = 50
    volume_type           = "gp2"
  }

  vpc_security_group_ids = [
    aws_security_group.application_security_group.id,
  ]


  tags = {
    Name = "${var.assignment} -  Ec2 Instance "
  }
}
