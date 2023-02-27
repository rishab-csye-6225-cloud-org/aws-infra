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

  //for testing purpose
  egress {
    description = "TCP traffic to DB PORT anywhere"
    to_port     = 5432
    from_port   = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "${var.assignment} - application security group"
  }
}


data "aws_ami" "ami_image" {
  executable_users = ["self"]
  most_recent      = true
  owners           = var.ami_owners

  filter {
    name   = "name"
    values = ["csye6225_*"]
  }
}


# //ec2 instance
resource "aws_instance" "web" {
  ami                         = data.aws_ami.ami_image.id
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

  iam_instance_profile = aws_iam_instance_profile.ec2_role_profile.name

  //user data script
  user_data = <<EOF
    #!/bin/bash
                      
                      ####################################################
                      
                      # Configuring Ec2 user data script #
                      
                      ####################################################
                      
                      cd /home/ec2-user/webapp
                      touch .env
                      
                      echo "DB_USER=csye6225" >> .env
                      echo "DB_NAME=csye6225" >> .env
                      echo "DB_PORT=5432" >> .env
                      echo "APP_PORT=9000" >> .env
                      echo "DB_HOSTNAME=${aws_db_instance.rds_db_instance.address}" >> .env
                      echo "DB_PASSWORD=${var.db_password}" >> .env
                    
                      sudo systemctl start webapp
                      sudo systemctl status webapp
                      sudo systemctl enable webapp
EOF


  tags = {
    Name = "${var.assignment} -  Ec2 Instance "
  }
}


//security group for rds instance
resource "aws_security_group" "database_security_group" {
  name   = "database"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.application_security_group.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_db_parameter_group" "postgres_parameter_group" {
  name   = "postgres-pg"
  family = "postgres14"
}

resource "aws_db_instance" "rds_db_instance" {
  allocated_storage      = 10
  identifier             = "csye6225"
  db_name                = "csye6225"
  engine                 = "postgres"
  engine_version         = "14.6"
  instance_class         = "db.t3.micro"
  username               = "csye6225"
  password               = var.db_password
  parameter_group_name   = aws_db_parameter_group.postgres_parameter_group.name
  multi_az               = false
  publicly_accessible    = false //now as per req
  db_subnet_group_name   = aws_db_subnet_group.private_subnet_group.name
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.database_security_group.id]

}

resource "aws_db_subnet_group" "private_subnet_group" {
  name       = "rds_private_subnet_group"
  subnet_ids = [aws_subnet.subnet_private[0].id, aws_subnet.subnet_private[1].id]

  tags = {
    Name = "RDS subnet group"
  }
}


//s3 
resource "aws_s3_bucket" "aws_s3_bucket" {
  bucket = "${random_string.s3_bucket_name.id}.${var.profile}"


  tags = {
    Name = "${var.assignment} - S3 bucket"
  }

}


resource "aws_s3_bucket_lifecycle_configuration" "s3_lifecycle_config" {
  bucket = aws_s3_bucket.aws_s3_bucket.id

  rule {

    id = "lifecycle"
    filter {}

    transition {
      days          = 30
      storage_class = "STANDARD_IA" # or "ONEZONE_IA"
    }


    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "s3_acl" {
  bucket = aws_s3_bucket.aws_s3_bucket.id
  acl    = "private"
}

//sse encrytion
resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_key_encryption" {
  bucket = aws_s3_bucket.aws_s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

//to generate random string
resource "random_string" "s3_bucket_name" {
  upper   = false
  lower   = true
  special = false
  length  = 3
}


