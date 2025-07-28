

provider "aws" {
  region = var.region
}


resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.proyecto_bogdan}-VPC"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = "${var.region}a"
  tags = {
    Name = "${var.proyecto_bogdan}-PublicSubnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.region}a"
  tags = {
    Name = "${var.proyecto_bogdan}-PrivateSubnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.proyecto_bogdan}-IGW"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "${var.proyecto_bogdan}-EIP"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  tags = {
    Name = "${var.proyecto_bogdan}-NAT-GW"
  }
  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.proyecto_bogdan}-PublicRouteTable"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = {
    Name = "${var.proyecto_bogdan}-PrivateRouteTable"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}


resource "aws_security_group" "alb" {
  name        = "${var.proyecto_bogdan}-alb-sg"
  description = "Permite trafico web HTTP y HTTPS"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "webserver" {
  name        = "${var.proyecto_bogdan}-webserver-sg"
  description = "Permite trafico desde el ALB"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "database" {
  name        = "${var.proyecto_bogdan}-database-sg"
  description = "Permite trafico desde los servidores web"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.webserver.id]
  }
}



resource "aws_lb" "main" {
  name               = "${var.proyecto_bogdan}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public.id]
}

resource "aws_lb_target_group" "main" {
  name     = "${var.proyecto_bogdan}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.proyecto_bogdan}-ec2-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.proyecto_bogdan}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_launch_template" "main" {
  name_prefix   = "${var.proyecto_bogdan}-lt-"
  image_id      = "ami-01e4449c34d3da9a5"
  instance_type = "t2.micro"
  
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  vpc_security_group_ids = [aws_security_group.webserver.id]
  
  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Desplegado con Terraform! IP: $(hostname -f)</h1>" > /var/www/html/index.html
              EOF
  )
  
  tags = {
    Name = "${var.proyecto_bogdan}-WebServer"
  }
}

resource "aws_autoscaling_group" "main" {
  name                = "${var.proyecto_bogdan}-asg"
  min_size            = 2
  max_size            = 2
  desired_capacity    = 2
  vpc_zone_identifier = [aws_subnet.private.id]
  
  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
  
  target_group_arns = [aws_lb_target_group.main.arn]
}

# --- 5. CAPA DE DATOS (RDS) ---

resource "aws_db_subnet_group" "main" {
  name       = "${var.proyecto_bogdan}-db-subnet-group"
  subnet_ids = [aws_subnet.private.id]
  tags = {
    Name = "${var.proyecto_bogdan}-DBSG"
  }
}

resource "aws_db_instance" "main" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t2.micro"
  db_name                = "${var.proyecto_bogdan}DB"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
}