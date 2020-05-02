terraform {
  required_version = ">= 0.10.3" # Local Values configuration feature is allowed only in higher versions of Terraform
}

##################################
# JUMPSERVER SECURITY GROUP
##################################

resource "aws_security_group" "jumpserver" {

  count = var.create_sg ? 1 : 0
  name        = format("%s-%s-jumpserver-sg", var.name, var.env)
  description = "Security Group for JumpServer Resources"
  vpc_id      = var.vpc-id

  tags = merge(var.tags_sg, {"Name" = format("%s-%s-jumpserver-sg", var.name, var.env)})
}

resource "aws_security_group_rule" "jumpserver_ingress" {
  count = var.create_sg ? length(var.jumpserver_ingress_rules) : 0

  security_group_id = aws_security_group.jumpserver[0].id
  type              = "ingress"

  cidr_blocks      = lookup(var.jumpserver_ingress_rules[count.index], "cidr_blocks")

  from_port = lookup(var.jumpserver_ingress_rules[count.index], "from_port", 0)
  to_port   = lookup(var.jumpserver_ingress_rules[count.index], "to_port", 0)
  protocol  = lookup(var.jumpserver_ingress_rules[count.index], "protocol", "tcp")
  description = lookup(var.jumpserver_ingress_rules[count.index], "description", "")
}

resource "aws_security_group_rule" "jumpserver_egress" {
  count = var.create_sg ? length(var.jumpserver_egress_rules) : 0

  security_group_id = aws_security_group.jumpserver[0].id
  type              = "egress"

  cidr_blocks      = lookup(var.jumpserver_egress_rules[count.index], "cidr_blocks")

  from_port = lookup(var.jumpserver_egress_rules[count.index], "from_port")
  to_port   = lookup(var.jumpserver_egress_rules[count.index], "to_port")
  protocol  = lookup(var.jumpserver_egress_rules[count.index], "protocol")
  description = lookup(var.jumpserver_egress_rules[count.index], "description", "")
}

##################################
# LOAD BALANCER SECURITY GROUP
##################################

resource "aws_security_group" "lb" {

  count = var.create_sg ? 1 : 0
  name        = format("%s-%s-lb-sg", var.name, var.env)
  description = "Security Group for Load Balancer"
  vpc_id      = var.vpc-id

  tags = merge(var.tags_sg, {"Name" = format("%s-%s-lb-sg", var.name, var.env)})
}

resource "aws_security_group_rule" "lb_ingress" {
  count = var.create_sg ? length(var.lb_ingress_rules) : 0

  security_group_id = aws_security_group.lb[0].id
  type              = "ingress"

  cidr_blocks      = lookup(var.lb_ingress_rules[count.index], "cidr_blocks")

  from_port = lookup(var.lb_ingress_rules[count.index], "from_port", 0)
  to_port   = lookup(var.lb_ingress_rules[count.index], "to_port", 0)
  protocol  = lookup(var.lb_ingress_rules[count.index], "protocol", "tcp")
  description = lookup(var.lb_ingress_rules[count.index], "description", "")
}

resource "aws_security_group_rule" "lb_egress" {
  count = var.create_sg ? length(var.lb_egress_rules) : 0

  security_group_id = aws_security_group.lb[0].id
  type              = "egress"

  cidr_blocks      = lookup(var.lb_egress_rules[count.index], "cidr_blocks")

  from_port = lookup(var.lb_egress_rules[count.index], "from_port")
  to_port   = lookup(var.lb_egress_rules[count.index], "to_port")
  protocol  = lookup(var.lb_egress_rules[count.index], "protocol")
  description = lookup(var.lb_egress_rules[count.index], "description", "")
}

##################################
# APPLICATION SECURITY GROUP
##################################

resource "aws_security_group" "app" {

  count = var.create_sg ? 1 : 0
  name        = format("%s-%s-app-sg", var.name, var.env)
  description = "Security Group for Load Balancer"
  vpc_id      = var.vpc-id

  tags = merge(var.tags_sg, {"Name" = format("%s-%s-app-sg", var.name, var.env)})
}

resource "aws_security_group_rule" "app_ingress" {
  count = var.create_sg ? length(var.app_ingress_rules) : 0

  security_group_id = aws_security_group.app[0].id
  type              = "ingress"

  cidr_blocks      = lookup(var.app_ingress_rules[count.index], "cidr_blocks")

  from_port = lookup(var.app_ingress_rules[count.index], "from_port", 0)
  to_port   = lookup(var.app_ingress_rules[count.index], "to_port", 0)
  protocol  = lookup(var.app_ingress_rules[count.index], "protocol", "tcp")
  description = lookup(var.app_ingress_rules[count.index], "description", "")
}

resource "aws_security_group_rule" "app_egress" {
  count = var.create_sg ? length(var.app_egress_rules) : 0

  security_group_id = aws_security_group.app[0].id
  type              = "egress"

  cidr_blocks      = lookup(var.app_egress_rules[count.index], "cidr_blocks")

  from_port = lookup(var.app_egress_rules[count.index], "from_port")
  to_port   = lookup(var.app_egress_rules[count.index], "to_port")
  protocol  = lookup(var.app_egress_rules[count.index], "protocol")
  description = lookup(var.app_egress_rules[count.index], "description", "")
}


##################################
# RDS DATABASE SECURITY GROUP
##################################

resource "aws_security_group" "rds" {

  count = var.create_sg ? 1 : 0
  name        = format("%s-%s-rds-sg", var.name, var.env)
  description = "Security Group for RDS Database"
  vpc_id      = var.vpc-id

  tags = merge(var.tags_sg, {"Name" = format("%s-%s-rds-sg", var.name, var.env)})
}

resource "aws_security_group_rule" "rds_ingress" {
  count = var.create_sg ? length(var.rds_ingress_rules) : 0

  security_group_id = aws_security_group.rds[0].id
  type              = "ingress"

  cidr_blocks      = lookup(var.rds_ingress_rules[count.index], "cidr_blocks")

  from_port = lookup(var.rds_ingress_rules[count.index], "from_port", 0)
  to_port   = lookup(var.rds_ingress_rules[count.index], "to_port", 0)
  protocol  = lookup(var.rds_ingress_rules[count.index], "protocol", "tcp")
  description = lookup(var.rds_ingress_rules[count.index], "description", "")
}

resource "aws_security_group_rule" "rds_egress" {
  count = var.create_sg ? length(var.rds_egress_rules) : 0

  security_group_id = aws_security_group.rds[0].id
  type              = "egress"

  cidr_blocks      = lookup(var.rds_egress_rules[count.index], "cidr_blocks")

  from_port = lookup(var.rds_egress_rules[count.index], "from_port")
  to_port   = lookup(var.rds_egress_rules[count.index], "to_port")
  protocol  = lookup(var.rds_egress_rules[count.index], "protocol")
  description = lookup(var.rds_egress_rules[count.index], "description", "")
}

##################################
# WEB SECURITY GROUP
##################################

resource "aws_security_group" "web" {

  count = var.create_sg ? 1 : 0
  name        = format("%s-%s-web-sg", var.name, var.env)
  description = "Security Group for web instances"
  vpc_id      = var.vpc-id

  tags = merge(var.tags_sg, {"Name" = format("%s-%s-web-sg", var.name, var.env)})
}

resource "aws_security_group_rule" "web_ingress" {
  count = var.create_sg ? length(var.web_ingress_rules) : 0

  security_group_id = aws_security_group.web[0].id
  type              = "ingress"

  cidr_blocks      = lookup(var.web_ingress_rules[count.index], "cidr_blocks")

  from_port = lookup(var.web_ingress_rules[count.index], "from_port", 0)
  to_port   = lookup(var.web_ingress_rules[count.index], "to_port", 0)
  protocol  = lookup(var.web_ingress_rules[count.index], "protocol", "tcp")
  description = lookup(var.web_ingress_rules[count.index], "description", "")
}

resource "aws_security_group_rule" "web_egress" {
  count = var.create_sg ? length(var.web_egress_rules) : 0

  security_group_id = aws_security_group.web[0].id
  type              = "egress"

  cidr_blocks      = lookup(var.web_egress_rules[count.index], "cidr_blocks")

  from_port = lookup(var.web_egress_rules[count.index], "from_port")
  to_port   = lookup(var.web_egress_rules[count.index], "to_port")
  protocol  = lookup(var.web_egress_rules[count.index], "protocol")
  description = lookup(var.web_egress_rules[count.index], "description", "")
}

##################################
# NOTIFICATION SECURITY GROUP
##################################

resource "aws_security_group" "notification" {

  count = var.create_sg ? 1 : 0
  name        = format("%s-%s-notification-sg", var.name, var.env)
  description = "Security Group for notification instances"
  vpc_id      = var.vpc-id

  tags = merge(var.tags_sg, {"Name" = format("%s-%s-notification-sg", var.name, var.env)})
}

resource "aws_security_group_rule" "notification_ingress" {
  count = var.create_sg ? length(var.notification_ingress_rules) : 0

  security_group_id = aws_security_group.notification[0].id
  type              = "ingress"

  cidr_blocks      = lookup(var.notification_ingress_rules[count.index], "cidr_blocks")

  from_port = lookup(var.notification_ingress_rules[count.index], "from_port", 0)
  to_port   = lookup(var.notification_ingress_rules[count.index], "to_port", 0)
  protocol  = lookup(var.notification_ingress_rules[count.index], "protocol", "tcp")
  description = lookup(var.notification_ingress_rules[count.index], "description", "")
}

resource "aws_security_group_rule" "notification_egress" {
  count = var.create_sg ? length(var.notification_egress_rules) : 0

  security_group_id = aws_security_group.notification[0].id
  type              = "egress"

  cidr_blocks      = lookup(var.notification_egress_rules[count.index], "cidr_blocks")

  from_port = lookup(var.notification_egress_rules[count.index], "from_port")
  to_port   = lookup(var.notification_egress_rules[count.index], "to_port")
  protocol  = lookup(var.notification_egress_rules[count.index], "protocol")
  description = lookup(var.notification_egress_rules[count.index], "description", "")
}

##################################
# JOB SECURITY GROUP
##################################

resource "aws_security_group" "job" {

  count = var.create_sg ? 1 : 0
  name        = format("%s-%s-job-sg", var.name, var.env)
  description = "Security Group for job instances"
  vpc_id      = var.vpc-id

  tags = merge(var.tags_sg, {"Name" = format("%s-%s-job-sg", var.name, var.env)})
}

resource "aws_security_group_rule" "job_ingress" {
  count = var.create_sg ? length(var.job_ingress_rules) : 0

  security_group_id = aws_security_group.job[0].id
  type              = "ingress"

  cidr_blocks      = lookup(var.job_ingress_rules[count.index], "cidr_blocks")

  from_port = lookup(var.job_ingress_rules[count.index], "from_port", 0)
  to_port   = lookup(var.job_ingress_rules[count.index], "to_port", 0)
  protocol  = lookup(var.job_ingress_rules[count.index], "protocol", "tcp")
  description = lookup(var.job_ingress_rules[count.index], "description", "")
}

resource "aws_security_group_rule" "job_egress" {
  count = var.create_sg ? length(var.job_egress_rules) : 0

  security_group_id = aws_security_group.job[0].id
  type              = "egress"

  cidr_blocks      = lookup(var.job_egress_rules[count.index], "cidr_blocks")

  from_port = lookup(var.job_egress_rules[count.index], "from_port")
  to_port   = lookup(var.job_egress_rules[count.index], "to_port")
  protocol  = lookup(var.job_egress_rules[count.index], "protocol")
  description = lookup(var.job_egress_rules[count.index], "description", "")
}

##################################
# CAPTCHA SECURITY GROUP
##################################

resource "aws_security_group" "captcha" {

  count = var.create_sg ? 1 : 0
  name        = format("%s-%s-captcha-sg", var.name, var.env)
  description = "Security Group for captcha instances"
  vpc_id      = var.vpc-id

  tags = merge(var.tags_sg, {"Name" = format("%s-%s-captcha-sg", var.name, var.env)})
}

resource "aws_security_group_rule" "captcha_ingress" {
  count = var.create_sg ? length(var.captcha_ingress_rules) : 0

  security_group_id = aws_security_group.captcha[0].id
  type              = "ingress"

  cidr_blocks      = lookup(var.captcha_ingress_rules[count.index], "cidr_blocks")

  from_port = lookup(var.captcha_ingress_rules[count.index], "from_port", 0)
  to_port   = lookup(var.captcha_ingress_rules[count.index], "to_port", 0)
  protocol  = lookup(var.captcha_ingress_rules[count.index], "protocol", "tcp")
  description = lookup(var.captcha_ingress_rules[count.index], "description", "")
}

resource "aws_security_group_rule" "captcha_egress" {
  count = var.create_sg ? length(var.captcha_egress_rules) : 0

  security_group_id = aws_security_group.captcha[0].id
  type              = "egress"

  cidr_blocks      = lookup(var.captcha_egress_rules[count.index], "cidr_blocks")

  from_port = lookup(var.captcha_egress_rules[count.index], "from_port")
  to_port   = lookup(var.captcha_egress_rules[count.index], "to_port")
  protocol  = lookup(var.captcha_egress_rules[count.index], "protocol")
  description = lookup(var.captcha_egress_rules[count.index], "description", "")
}
