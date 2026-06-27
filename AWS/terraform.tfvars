ports         = [22, 80, 443, 3306, 27017, 1080]
instance_type = "t2.micro"
image_id      = "ami-007020fd9c84e18c7"
  access_key = "xxxxxxxxxxxxxx"
  secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxx"

availability_zone = "ap-south-1a"


# #Load balancer
# lb_name              = "my-load-balancer"
# lb_internal          = false
# lb_listener_port     = 80
# lb_target_port       = 8080
# lb_health_check_path = "/"
