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
  name        = "application"
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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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
                      
                      echo "DB_USER=${var.db_user}" >> .env
                      echo "DB_NAME=${var.db_name}" >> .env
                      echo "DB_PORT=${aws_db_instance.rds_db_instance.port}" >> .env
                      echo "APP_PORT=${var.app_port}" >> .env
                      echo "DB_HOSTNAME=${aws_db_instance.rds_db_instance.address}" >> .env
                      echo "DB_PASSWORD=${var.db_password}" >> .env
                      echo "AWS_BUCKET_NAME=${aws_s3_bucket.aws_s3_bucket.bucket}" >> .env


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
}


resource "aws_db_parameter_group" "postgres_parameter_group" {
  name   = "postgres-pg"
  family = "postgres14"
}

resource "aws_db_instance" "rds_db_instance" {
  allocated_storage      = var.db_storage_size
  identifier             = "csye6225"
  db_name                = var.db_name
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = "db.t3.micro"
  username               = var.db_user
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
  subnet_ids = [aws_subnet.subnet_private[0].id, aws_subnet.subnet_private[1].id, aws_subnet.subnet_private[2].id]

  tags = {
    Name = "RDS subnet group"
  }
}

//s3 
resource "aws_s3_bucket" "aws_s3_bucket" {
  bucket        = "${random_string.s3_bucket_name.id}.${var.profile}"
  force_destroy = true

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



resource "aws_s3_bucket_server_side_encryption_configuration" "s3_key_encryption" {
  bucket = aws_s3_bucket.aws_s3_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

//to generate random string
resource "random_string" "s3_bucket_name" {
  upper   = false
  lower   = true
  special = false
  length  = 5
}

//s3 bucket policy
#Create an IAM Policy
resource "aws_iam_policy" "iam_policy_s3_access" {
  name        = "WebAppS3"
  description = "Provides permission to access S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.aws_s3_bucket.id}",
        "arn:aws:s3:::${aws_s3_bucket.aws_s3_bucket.id}/*"]
      },
    ]
  })

}


//creating an iam role for ec2 instance
resource "aws_iam_role" "ec2_role" {
  name = "EC2-CSYE6225"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "RoleForEC2"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

//attaching the policy to role
resource "aws_iam_policy_attachment" "policy_role_attach" {
  name       = "policy_role_attach"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.iam_policy_s3_access.arn
}

//need to create an instance profile for ec2 role as it acts as a container for the created role
resource "aws_iam_instance_profile" "ec2_role_profile" {
  name = "ec2_role_profile"
  role = aws_iam_role.ec2_role.name
}

//public access block
resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.aws_s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

//AWS Route 53 zone data source
data "aws_route53_zone" "selected_zone" {
  name         = var.domain_name
  private_zone = false
}

//AWS Route 53 record
resource "aws_route53_record" "server_mapping_record" {
  //zone_id = var.zone_id
  zone_id = data.aws_route53_zone.selected_zone.zone_id
  name    = var.domain_name
  type    = var.record_type
  ttl     = var.ttl_value
  records = [aws_instance.web.public_ip]
}

