# Variables
# variable "vpc_cidr_block" {
#   default = "10.0.0.0/16"
# }
# variable "vpc_id" {
#   default = "aws_vpc.default_vpc.id"
# }

# variable "subnet_cidr_block" {
#   default = "10.0.1.0/24"
# }

variable "availability_zone" {
  type = string
}



variable "ports" {
  type = list(number)
}

variable "instance_type" {
  type = string
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "image_id" {
  type = string
}

# variable "lb_name" {
#   type = string
# }
# variable "lb_internal" {
#   type = string
# }
# variable "lb_listener_port" {
#   type = number
# }
# variable "lb_target_port" {
#   type = number
# }
# variable "lb_health_check_path" {
#   type = string
# }