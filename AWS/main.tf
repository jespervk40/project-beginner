# Variables
variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidr_blocks" {
  default = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

# Creating VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Creating Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Creating Public Subnets
resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidr_blocks)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true
}

# Creating Private Subnets
resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zone
  map_public_ip_on_launch = false
}

# Creating Route Table for Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# Associating Public Subnets with Public Route Table
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.public_subnet_cidr_blocks)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Creating Security Groups
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebSecurityGroup"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "Security group for application servers"
  vpc_id      = aws_vpc.my_vpc.id

  # Define ingress and egress rules as needed for your application tier

  tags = {
    Name = "AppSecurityGroup"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Security group for database servers"
  vpc_id      = aws_vpc.my_vpc.id

  # Define ingress and egress rules as needed for your database tier

  tags = {
    Name = "DbSecurityGroup"
  }
}

# Creating Instances
resource "aws_instance" "web_instances" {
  count         = 2
  ami           = var.image_id  
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnets[count.index].id
  security_groups = [aws_security_group.web_sg.id]
}

resource "aws_instance" "app_instances" {
  count         = 2
  ami           = var.image_id  
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnets[count.index].id
  security_groups = [aws_security_group.app_sg.id]
}

resource "aws_instance" "db_instance" {
  ami           = var.image_id  
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnets[0].id  # Assuming only one private subnet for the database
  security_groups = [aws_security_group.db_sg.id]
}



# # Load Balancer
# resource "aws_lb" "my_lb" {
#   name               = var.lb_name
#   internal           = var.lb_internal
#   load_balancer_type = "application"

#   # Listener configuration
#   dynamic "listener" {
#     for_each = var.public_subnet_cidr_blocks

#     content {
#       port            = var.lb_listener_port
#       protocol        = "HTTP"
#       default_action {
#         type             = "forward"
#         target_group_arn = aws_lb_target_group.my_target_group.arn
#       }
#     }
#   }

#   # Health check configuration
#   enable_deletion_protection         = false
#   idle_timeout                       = 60
#   enable_cross_zone_load_balancing   = true
#   enable_http2                       = true

#   dynamic "tags" {
#     for_each = {
#       Name = var.lb_name
#     }

#     content {
#       key   = tags.key
#       value = tags.value
#     }
#   }
# }

# # Target Group
# resource "aws_lb_target_group" "my_target_group" {
#   name     = "my-target-group"
#   port     = var.lb_target_port
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.my_vpc.id

#   health_check {
#     path                = var.lb_health_check_path
#     interval            = 30
#     timeout             = 10
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     matcher             = "200-399"
#   }
# }

# # Load Balancer Target Group Attachment
# resource "aws_lb_target_group_attachment" "my_target_group_attachment" {
#   target_group_arn = aws_lb_target_group.my_target_group.arn
#   target_id        = aws_instance.web_instances[0].id  # Replace with your instance ID
#   port             = var.lb_target_port
# }

