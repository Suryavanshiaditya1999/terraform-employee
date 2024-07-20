
resource "aws_vpc" "ot_microservices_dev" {
  cidr_block       = "10.0.0.0/25"
  instance_tenancy = "default"
  tags = {
    Name = "ot-micro-vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
 vpc_id            = aws_vpc.ot_microservices_dev.id
 cidr_block        = "10.0.0.0/28"
 availability_zone = "us-east-2a"
 map_public_ip_on_launch = true
 tags = {
   Name = "Public Subnet 1"
 }
}

resource "aws_subnet" "public_subnet_2" {
 vpc_id            = aws_vpc.ot_microservices_dev.id
 cidr_block        = "10.0.0.16/28"
 availability_zone = "us-east-2b"
 map_public_ip_on_launch = true
 tags = {
   Name = "Public Subnet 2"
 }
}

resource "aws_subnet" "frontend_subnet" {
 vpc_id            = aws_vpc.ot_microservices_dev.id
 cidr_block        = "10.0.0.32/28"
 availability_zone = "us-east-2a"
 tags = {
   Name = "Frontend Subnet"
 }
}

resource "aws_subnet" "application_subnet" {
 vpc_id            = aws_vpc.ot_microservices_dev.id
 cidr_block        = "10.0.0.48/28"
 availability_zone = "us-east-2a"
 tags = {
   Name = "Application Subnet"
 }
}

resource "aws_subnet" "database_subnet" {
 vpc_id            = aws_vpc.ot_microservices_dev.id
 cidr_block        = "10.0.0.64/28"
 availability_zone = "us-east-2a"
 tags = {
   Name = "Database Subnet"
 }
}

# ROUTE TABLE

# public rt

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ot_microservices_dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

# private rt

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.ot_microservices_dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "Private Route Table"
  }
}

# ROUTE TABLE ASSOSCIATION

resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "frontend_subnet" {
  subnet_id      = aws_subnet.frontend_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "application_subnet" {
  subnet_id      = aws_subnet.application_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "database_subnet" {
  subnet_id      = aws_subnet.database_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# NACL

# public nacl

resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.ot_microservices_dev.id


  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }


  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

   ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  tags = {
    Name = "Public NACL"
  }
}

resource "aws_network_acl_association" "nacl_public_subnet_assoscition_1" {
  network_acl_id = aws_network_acl.public_nacl.id
  subnet_id      = aws_subnet.public_subnet_1.id
}

resource "aws_network_acl_association" "nacl_public_subnet_assoscition_2" {
  network_acl_id = aws_network_acl.public_nacl.id
  subnet_id      = aws_subnet.public_subnet_2.id
}


# database_nacl

resource "aws_network_acl" "database_nacl" {
  vpc_id = aws_vpc.ot_microservices_dev.id


  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.0.0/28"
    from_port  = 22
    to_port    = 22
  }


  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "10.0.0.48/28"
    from_port  = 6379
    to_port    = 6379
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "10.0.0.48/28"
    from_port  = 5432
    to_port    = 5432
  }

   ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 9042
    to_port    = 9042
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.0.0/28"
    from_port  = 22
    to_port    = 22
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "10.0.0.48/28"
    from_port  = 1024
    to_port    = 65535
  }

   egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "Database Nacl"
  }
}

resource "aws_network_acl_association" "nacl_database_assoscition" {
  network_acl_id = aws_network_acl.database_nacl.id
  subnet_id      = aws_subnet.database_subnet.id
}


# frontend_nacl

resource "aws_network_acl" "frontend_nacl" {
  vpc_id = aws_vpc.ot_microservices_dev.id


  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.0.0/28"
    from_port  = 3000
    to_port    = 3000
  }


  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "10.0.0.0/28"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 140
    action     = "allow"
    cidr_block = "10.0.0.48/28"
    from_port  = 3000
    to_port    = 3000
  }

   egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.0.0/28"
    from_port  = 22
    to_port    = 22
  }

   egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "10.0.0.0/28"
    from_port  = 1024
    to_port    = 65535
  }

   egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "10.0.0.16/28"
    from_port  = 1024 
    to_port    = 65535
  }

  tags = {
    Name = "Frontend Nacl"
  }

}

resource "aws_network_acl_association" "nacl_frontend_assoscition" {
  network_acl_id = aws_network_acl.frontend_nacl.id
  subnet_id      = aws_subnet.frontend_subnet.id
}

# appliation_nacl

resource "aws_network_acl" "application_nacl" {
  vpc_id = aws_vpc.ot_microservices_dev.id


  ingress {
    protocol   = "tcp"
    rule_no    = 10
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

   ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.0.0/28"
    from_port  = 22
    to_port    = 22
  }

   ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "10.0.0.0/28"
    from_port  = 8080
    to_port    = 8080
  }

   ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "10.0.0.16/28"
    from_port  = 8080
    to_port    = 8080
  }

   ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "10.0.0.32/28"
    from_port  = 8080
    to_port    = 8080
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 140
    action     = "allow"
    cidr_block = "10.0.0.0/28"
    from_port  = 443
    to_port    = 443  
  }

   ingress {
    protocol   = "tcp"
    rule_no    = 150
    action     = "allow"
    cidr_block = "10.0.0.16/28"
    from_port  = 443
    to_port    = 443  
  }

   ingress {
    protocol   = "tcp"
    rule_no    = 160
    action     = "allow"
    cidr_block = "10.0.0.32/28"
    from_port  = 443
    to_port    = 443  
  }


   egress {
    protocol   = "tcp"
    rule_no    = 1
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }
  
   egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.0.0/28"
    from_port  = 22
    to_port    = 22
  }

   egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "10.0.0.0/28"
    from_port  = 1024 
    to_port    = 65535
  }

   egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "10.0.0.16/28"
    from_port  = 1024 
    to_port    = 65535
  }


  tags = {
    Name = "Application Nacl"
  }

}

resource "aws_network_acl_association" "nacl_application_assoscition" {
  network_acl_id = aws_network_acl.application_nacl.id
  subnet_id      = aws_subnet.application_subnet.id
}


# INTERNET GATEWAY

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ot_microservices_dev.id

  tags = {
    Name = "igw1-ot-micro"
  }
}

resource "aws_eip" "elasticip" {
  domain = "vpc"
  tags = {
    Name = "ot-micro-elasticip"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elasticip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "NAT Gateway"
  }
}


# ROUTE 53

resource "aws_route53_zone" "primary" {
  name = "indiantech.fun"
  tags = {
    Environment = "dev"
  }
}



# BASTION

# bastion security grouo

resource "aws_security_group" "bastion_security_group" {
  vpc_id = aws_vpc.ot_microservices_dev.id
  name = "bastion-security-group"

  tags = {
    Name = "bastion-security-group"
  }
  
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }
}

# ALB SECURITY GROUP

resource "aws_security_group" "alb_security_group" {
  vpc_id = aws_vpc.ot_microservices_dev.id
  name = "alb-security-group"

  tags = {
    Name = "alb-security-group"
  }
  
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
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
    # ipv6_cidr_blocks = ["::/0"]
  }
}


# FRONTEND

resource "aws_security_group" "frontend_security_group" {
  vpc_id = aws_vpc.ot_microservices_dev.id
  name = "frontend-security-group"

  tags = {
    Name = "frontend-security-group"
  }
  
  ingress {
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [aws_security_group.bastion_security_group.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }
}


# frontend instance

resource "aws_instance" "frontend_app" {
  # ami to be replaced
  ami           = "ami-0862be96e41dcbf74"
  subnet_id = aws_subnet.frontend_subnet.id
  vpc_security_group_ids = [ aws_security_group.frontend_security_group.id ]
  instance_type = "t2.micro"

  tags = {
    Name = "Frontend"
  }
}

# target group and attachment

resource "aws_lb_target_group" "frotend_target_group" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = aws_vpc.ot_microservices_dev.id
}

resource "aws_lb_target_group_attachment" "frontend_target_group_attachment" {
  target_group_arn = aws_lb_target_group.frotend_target_group.arn
  target_id        = aws_instance.frontend_app.id
  port             = 80
}

# load balancer

resource "aws_lb" "test" {
  name               = "frontend-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = [aws_subnet.public_subnet_1.id , aws_subnet.public_subnet_2.id]
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frotend_target_group.arn
  }
}


# launch template

# resource "aws_launch_template" "frontend_launch_template" {
#   name = "frontend-template"

#   block_device_mappings {
#     device_name = "/dev/sdf"

#     ebs {
#       volume_size = 10
#       volume_type = "gp3"
#     }
#   }

#   network_interfaces {
#     subnet_id                   = aws_subnet.frontend_subnet.id
#     associate_public_ip_address = false
#     security_groups             = [aws_security_group.frontend_security_group.id]
#   }

#   key_name      = "one"
#   # ami to be replaced with actual ami currently not right
#   image_id      = "ami-0862be96e41dcbf74"
#   instance_type = "t2.micro"

#   tag_specifications {
#     resource_type = "instance"

#     tags = {
#       Name = "application"
#     }
#   }
# }



# ATTENDANCE



# EMPLOYEE

resource "aws_security_group" "employee_security_group" {
  vpc_id = aws_vpc.ot_microservices_dev.id
  name = "employee-security-group"

  tags = {
    Name = "employee-security-group"
  }
  
  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [aws_security_group.bastion_security_group.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }
}