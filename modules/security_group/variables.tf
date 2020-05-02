
variable "tags_sg" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = ""
}

variable "env" {
  description = "Environment to be used on all the resources as identifier"
  default     = ""
}

variable "vpc-id" {
  description = "VPC id where security groups should be created"
  default = ""
}

variable "create_sg" {
  description = "To create security group and all rules"
  default = "false"
}

# jumpserver security groups
variable "jumpserver_ingress_rules" {
  description = "Ingress rules for JumpServer resources"
  default = []
}

variable "jumpserver_egress_rules" {
  description = "Egress rules for JumpServer resources"
  default = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = 0
      to_port = 0
      protocol = "all"
      description = "Allow all connections to internet"
    },
  ]
}

# LoadBalancer Security Group
variable "lb_ingress_rules" {
  description = "Ingress rules for Load Balancer"
  default = []
}

variable "lb_egress_rules" {
  description = "Egress rules for Load Balancer"
  default = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = 0
      to_port = 0
      protocol = "all"
      description = "Allow all connections to internet"
    }
  ]
}

# Application security group
variable "app_ingress_rules" {
  description = "Ingress rules for application resources with CIDR blocks as source"
  default = []
}

variable "app_egress_rules" {
  description = "Egress rules for application resources"
  default = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = 0
      to_port = 0
      protocol = "all"
      description = "Allow all connections to internet"
    }
  ]
}

# RDS security group
variable "rds_ingress_rules" {
  description = "Ingress rules for RDS Database resources"
  default = []
}

variable "rds_egress_rules" {
  description = "Egress rules for RDS Database resources"
  default = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = 0
      to_port = 0
      protocol = "all"
      description = "Allow all connections to internet"
    }
  ]
}

# Web security group
variable "web_ingress_rules" {
  description = "Ingress rules for Web resources"
  default = []
}

variable "web_egress_rules" {
  description = "Egress rules for Web resources"
  default = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = 0
      to_port = 0
      protocol = "all"
      description = "Allow all connections to internet"
    }
  ]
}

# Notificatioin security group
variable "notification_ingress_rules" {
  description = "Ingress rules for Notification resources"
  default = []
}

variable "notification_egress_rules" {
  description = "Egress rules for Notification resources"
  default = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = 0
      to_port = 0
      protocol = "all"
      description = "Allow all connections to internet"
    }
  ]
}

# Job security group
variable "job_ingress_rules" {
  description = "Ingress rules for job resources"
  default = []
}

variable "job_egress_rules" {
  description = "Egress rules for job resources"
  default = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = 0
      to_port = 0
      protocol = "all"
      description = "Allow all connections to internet"
    }
  ]
}


# Captcha security group
variable "captcha_ingress_rules" {
  description = "Ingress rules for Captcha resources"
  default = []
}

variable "captcha_egress_rules" {
  description = "Egress rules for Captcha resources"
  default = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = 0
      to_port = 0
      protocol = "all"
      description = "Allow all connections to internet"
    }
  ]
}
