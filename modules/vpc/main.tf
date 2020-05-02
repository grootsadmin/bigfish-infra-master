terraform {
  required_version = ">= 0.10.3" # Local Values configuration feature is allowed only in higher versions of Terraform
}

locals {
  max_subnet_length = max(length(var.app_subnets), length(var.web_subnets), length(var.notification_subnets), length(var.captcha_subnets))
  nat_gateway_count = var.single_nat_gateway ? 1 : (var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length)

  # Use `local.vpc_id` to give tell Terraform that subnets should be deleted before secondary CIDR blocks can be free
  vpc_id = "${element(concat(aws_vpc_ipv4_cidr_block_association.this.*.vpc_id, aws_vpc.this.*.id, list("")), 0)}"

}

######
# VPC
######
resource "aws_vpc" "this" {
  count = var.create_vpc ? 1 : 0

  cidr_block                       = var.cidr
  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block

  tags = merge({"Name" = format("%s-%s-vpc", var.name, var.env)}, var.tags)
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count = var.create_vpc && length(var.secondary_cidr_blocks) > 0 ? length(var.secondary_cidr_blocks) : 0

  vpc_id = aws_vpc.this[0].id

  cidr_block = element(var.secondary_cidr_blocks, count.index)
}

###################
# Internet Gateway
###################
resource "aws_internet_gateway" "this" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge({"Name" = format("%s-%s-igw", var.name, var.env)}, var.tags)
}

################
# Publiс/JumpServer routes
################
resource "aws_route_table" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge({"Name" = format("%s-%s-jumpserver-rt", var.name, var.env)}, var.tags)
}

resource "aws_route" "public_internet_gateway" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

################
# Load Balancer routes
################
resource "aws_route_table" "lb" {
  count = var.create_vpc && length(var.lb_subnets) > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge({"Name" = format("%s-%s-lb-rt", var.name, var.env)}, var.tags)
}

resource "aws_route" "lb_internet_gateway" {
  count = var.create_vpc && length(var.lb_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.lb[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}


#################
# app routes
# There are as many routing tables as the number of NAT gateways
#################
resource "aws_route_table" "app" {
  count = var.create_vpc && local.max_subnet_length > 0 ? local.nat_gateway_count : 0

  vpc_id = local.vpc_id

  tags = merge({"Name" = (var.single_nat_gateway ? "${var.name}-${var.env}-app-rt" : format("%s-${var.env}-app-%s-rt", var.name, element(var.azs, count.index)))}, var.tags)
}

#################
# Web routes
# There are as many routing tables as the number of NAT gateways
#################
resource "aws_route_table" "web" {
  count = var.create_vpc && local.max_subnet_length > 0 ? local.nat_gateway_count : 0

  vpc_id = local.vpc_id

  tags = merge({"Name" = (var.single_nat_gateway ? "${var.name}-${var.env}-web-rt" : format("%s-${var.env}-web-%s-rt", var.name, element(var.azs, count.index)))}, var.tags)
}

#################
# Notification routes
# There are as many routing tables as the number of NAT gateways
#################
resource "aws_route_table" "notification" {
  count = var.create_vpc && local.max_subnet_length > 0 ? local.nat_gateway_count : 0

  vpc_id = local.vpc_id

  tags = merge({"Name" = (var.single_nat_gateway ? "${var.name}-${var.env}-notification-rt" : format("%s-${var.env}-notification-%s-rt", var.name, element(var.azs, count.index)))}, var.tags)
}


#################
# Captcha routes
# There are as many routing tables as the number of NAT gateways
#################
resource "aws_route_table" "captcha" {
  count = var.create_vpc && local.max_subnet_length > 0 ? local.nat_gateway_count : 0

  vpc_id = local.vpc_id

  tags = merge({"Name" = (var.single_nat_gateway ? "${var.name}-${var.env}-captcha-rt" : format("%s-${var.env}-captcha-%s-rt", var.name, element(var.azs, count.index)))}, var.tags)
}

#################
# rds routes
#################
resource "aws_route_table" "rds" {
  count = var.create_vpc && var.create_rds_subnet_route_table && length(var.rds_subnets) > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(var.tags, {"Name" = "${var.name}-${var.env}-rds-rt"})
}

resource "aws_route" "rds_internet_gateway" {
  count = var.create_vpc && var.create_rds_subnet_route_table && length(var.rds_subnets) > 0 && var.create_rds_internet_gateway_route ? 1 : 0

  route_table_id         = aws_route_table.rds[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

################
# Public/JumpServer subnet
################
resource "aws_subnet" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  vpc_id                  = local.vpc_id
  cidr_block              = element(var.public_subnets, count.index)
  # availability_zone       = element(var.azs, count.index)
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = var.map_public_ip_on_launch

  # tags = merge({"Name" = format("%s-${var.env}-jumpserver-%s-subnet", var.name, element(var.azs, count.index))}, var.tags)
  tags = merge({"Name" = format("%s-${var.env}-jumpserver-ap-south-1b-subnet", var.name)}, var.tags)
}

################
# Load Balancer subnet
################
resource "aws_subnet" "lb" {
  count = var.create_vpc && length(var.lb_subnets) > 0 ? length(var.lb_subnets) : 0

  vpc_id                  = local.vpc_id
  cidr_block              = element(var.lb_subnets, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = var.lb_map_public_ip_on_launch

  tags = merge({"Name" = format("%s-${var.env}-lb-%s-subnet", var.name, element(var.azs, count.index))}, var.tags)
}


#################
# app subnet
#################
resource "aws_subnet" "app" {
  count = var.create_vpc && length(var.app_subnets) > 0 ? length(var.app_subnets) : 0

  vpc_id            = local.vpc_id
  cidr_block        = element(var.app_subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = merge({"Name" = format("%s-${var.env}-app-%s-subnet", var.name, element(var.azs, count.index))}, var.tags)

  # depends_on = ["aws_nat_gateway.this", "aws_route.app_nat_gateway", "aws_route.worker_nat_gateway"]
  depends_on = [aws_nat_gateway.this, aws_route.app_nat_gateway]
}

#################
# web subnet
#################
resource "aws_subnet" "web" {
  count = var.create_vpc && length(var.web_subnets) > 0 ? length(var.web_subnets) : 0

  vpc_id            = local.vpc_id
  cidr_block        = element(var.web_subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = merge({"Name" = format("%s-${var.env}-web-%s-subnet", var.name, element(var.azs, count.index))}, var.tags)

  depends_on = [aws_nat_gateway.this]
}

#################
# notification subnet
#################
resource "aws_subnet" "notification" {
  count = var.create_vpc && length(var.notification_subnets) > 0 ? length(var.notification_subnets) : 0

  vpc_id            = local.vpc_id
  cidr_block        = element(var.notification_subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = merge({"Name" = format("%s-${var.env}-notification-%s-subnet", var.name, element(var.azs, count.index))}, var.tags)

  depends_on = [aws_nat_gateway.this]
}

#################
# Captcha subnet
#################
resource "aws_subnet" "captcha" {
  count = var.create_vpc && length(var.captcha_subnets) > 0 ? length(var.captcha_subnets) : 0

  vpc_id            = local.vpc_id
  cidr_block        = element(var.captcha_subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = merge({"Name" = format("%s-${var.env}-captcha-%s-subnet", var.name, element(var.azs, count.index))}, var.tags)

  depends_on = [aws_nat_gateway.this]
}

##################
# rds subnet
##################
resource "aws_subnet" "rds" {
  count = var.create_vpc && length(var.rds_subnets) > 0 ? length(var.rds_subnets) : 0

  vpc_id            = local.vpc_id
  cidr_block        = element(var.rds_subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = merge({"Name" = format("%s-${var.env}-rds-%s-subnet", var.name, element(var.azs, count.index))}, var.tags)
}

resource "aws_db_subnet_group" "rds" {
  count = var.create_vpc && length(var.rds_subnets) > 0 && var.create_rds_subnet_group ? 1 : 0

  name        = "${lower(var.name)}-rds-subnet-group"
  description = "rds subnet group for ${var.name}"
  subnet_ids  = aws_subnet.rds[*].id

  tags = merge({"Name" = format("%s-${var.env}-rds-subnetgroup", var.name)}, var.tags)
}



########################
# Public/JumpServer Network ACLs
########################
resource "aws_network_acl" "public" {
  count = var.create_vpc && var.public_dedicated_network_acl && length(var.public_subnets) > 0 ? 1 : 0

  # vpc_id     = "${element(concat(aws_vpc.this.*.id, list("")), 0)}"
  vpc_id     = element(aws_vpc.this[*].id, 0)
  # subnet_ids = ["${aws_subnet.public.*.id}"]
  subnet_ids = aws_subnet.public[*].id

  tags = merge({"Name" = format("%s-${var.env}-jumpserver-nacl", var.name)}, var.tags)
}

resource "aws_network_acl_rule" "public_inbound" {
  count = var.create_vpc && var.public_dedicated_network_acl && length(var.public_subnets) > 0 ? length(var.public_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.public[0].id

  egress      = false
  rule_number = lookup(var.public_inbound_acl_rules[count.index], "rule_number")
  rule_action = lookup(var.public_inbound_acl_rules[count.index], "rule_action")
  from_port   = lookup(var.public_inbound_acl_rules[count.index], "from_port")
  to_port     = lookup(var.public_inbound_acl_rules[count.index], "to_port")
  protocol    = lookup(var.public_inbound_acl_rules[count.index], "protocol")
  cidr_block  = lookup(var.public_inbound_acl_rules[count.index], "cidr_block")
}

resource "aws_network_acl_rule" "public_outbound" {
  count = var.create_vpc && var.public_dedicated_network_acl && length(var.public_subnets) > 0 ? length(var.public_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.public[0].id

  egress      = true
  rule_number = lookup(var.public_outbound_acl_rules[count.index], "rule_number")
  rule_action = lookup(var.public_outbound_acl_rules[count.index], "rule_action")
  from_port   = lookup(var.public_outbound_acl_rules[count.index], "from_port")
  to_port     = lookup(var.public_outbound_acl_rules[count.index], "to_port")
  protocol    = lookup(var.public_outbound_acl_rules[count.index], "protocol")
  cidr_block  = lookup(var.public_outbound_acl_rules[count.index], "cidr_block")
}


########################
# Load Balancer Network ACLs
########################
resource "aws_network_acl" "lb" {
  count = var.create_vpc && var.lb_dedicated_network_acl && length(var.lb_subnets) > 0 ? 1 : 0

  # vpc_id     = "${element(concat(aws_vpc.this.*.id, list("")), 0)}"
  # subnet_ids = ["${aws_subnet.lb.*.id}"]
  vpc_id     = element(aws_vpc.this[*].id, 0)
  subnet_ids = aws_subnet.lb[*].id

  tags = merge({"Name" = format("%s-${var.env}-lb-nacl", var.name)}, var.tags)
}

resource "aws_network_acl_rule" "lb_inbound" {
  count = var.create_vpc && var.lb_dedicated_network_acl && length(var.lb_subnets) > 0 ? length(var.lb_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.lb[0].id

  egress      = false
  rule_number = lookup(var.lb_inbound_acl_rules[count.index], "rule_number")
  rule_action = lookup(var.lb_inbound_acl_rules[count.index], "rule_action")
  from_port   = lookup(var.lb_inbound_acl_rules[count.index], "from_port")
  to_port     = lookup(var.lb_inbound_acl_rules[count.index], "to_port")
  protocol    = lookup(var.lb_inbound_acl_rules[count.index], "protocol")
  cidr_block  = lookup(var.lb_inbound_acl_rules[count.index], "cidr_block")
}

resource "aws_network_acl_rule" "lb_outbound" {
  count = var.create_vpc && var.lb_dedicated_network_acl && length(var.lb_subnets) > 0 ? length(var.lb_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.lb[0].id

  egress      = true
  rule_number = lookup(var.lb_outbound_acl_rules[count.index], "rule_number")
  rule_action = lookup(var.lb_outbound_acl_rules[count.index], "rule_action")
  from_port   = lookup(var.lb_outbound_acl_rules[count.index], "from_port")
  to_port     = lookup(var.lb_outbound_acl_rules[count.index], "to_port")
  protocol    = lookup(var.lb_outbound_acl_rules[count.index], "protocol")
  cidr_block  = lookup(var.lb_outbound_acl_rules[count.index], "cidr_block")
}


#######################
# app Network ACLs
#######################
resource "aws_network_acl" "app" {
  count = var.create_vpc && var.app_dedicated_network_acl && length(var.app_subnets) > 0 ? 1 : 0

  vpc_id     = element(aws_vpc.this[*].id, 0)
  subnet_ids = aws_subnet.app[*].id

  tags = merge({"Name" = format("%s-${var.env}-app-nacl", var.name)}, var.tags)
}

resource "aws_network_acl_rule" "app_inbound" {
  count = var.create_vpc && var.app_dedicated_network_acl && length(var.app_subnets) > 0 ? length(var.app_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.app[0].id

  egress      = false
  rule_number = lookup(var.app_inbound_acl_rules[count.index], "rule_number")
  rule_action = lookup(var.app_inbound_acl_rules[count.index], "rule_action")
  from_port   = lookup(var.app_inbound_acl_rules[count.index], "from_port")
  to_port     = lookup(var.app_inbound_acl_rules[count.index], "to_port")
  protocol    = lookup(var.app_inbound_acl_rules[count.index], "protocol")
  cidr_block  = lookup(var.app_inbound_acl_rules[count.index], "cidr_block")
}

resource "aws_network_acl_rule" "app_outbound" {
  count = var.create_vpc && var.app_dedicated_network_acl && length(var.app_subnets) > 0 ? length(var.app_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.app[0].id

  egress      = true
  rule_number = lookup(var.app_outbound_acl_rules[count.index], "rule_number")
  rule_action = lookup(var.app_outbound_acl_rules[count.index], "rule_action")
  from_port   = lookup(var.app_outbound_acl_rules[count.index], "from_port")
  to_port     = lookup(var.app_outbound_acl_rules[count.index], "to_port")
  protocol    = lookup(var.app_outbound_acl_rules[count.index], "protocol")
  cidr_block  = lookup(var.app_outbound_acl_rules[count.index], "cidr_block")
}


#######################
# web Network ACLs
#######################
resource "aws_network_acl" "web" {
  count = var.create_vpc && var.web_dedicated_network_acl && length(var.web_subnets) > 0 ? 1 : 0

  vpc_id     = element(aws_vpc.this[*].id, 0)
  subnet_ids = aws_subnet.web[*].id

  tags = merge({"Name" = format("%s-${var.env}-web-nacl", var.name)}, var.tags)
}

resource "aws_network_acl_rule" "web_inbound" {
  count = var.create_vpc && var.web_dedicated_network_acl && length(var.web_subnets) > 0 ? length(var.web_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.web[0].id

  egress      = false
  rule_number = lookup(var.web_inbound_acl_rules[count.index], "rule_number")
  rule_action = lookup(var.web_inbound_acl_rules[count.index], "rule_action")
  from_port   = lookup(var.web_inbound_acl_rules[count.index], "from_port")
  to_port     = lookup(var.web_inbound_acl_rules[count.index], "to_port")
  protocol    = lookup(var.web_inbound_acl_rules[count.index], "protocol")
  cidr_block  = lookup(var.web_inbound_acl_rules[count.index], "cidr_block")
}

resource "aws_network_acl_rule" "web_outbound" {
  count = var.create_vpc && var.web_dedicated_network_acl && length(var.web_subnets) > 0 ? length(var.web_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.web[0].id

  egress      = true
  rule_number = lookup(var.web_outbound_acl_rules[count.index], "rule_number")
  rule_action = lookup(var.web_outbound_acl_rules[count.index], "rule_action")
  from_port   = lookup(var.web_outbound_acl_rules[count.index], "from_port")
  to_port     = lookup(var.web_outbound_acl_rules[count.index], "to_port")
  protocol    = lookup(var.web_outbound_acl_rules[count.index], "protocol")
  cidr_block  = lookup(var.web_outbound_acl_rules[count.index], "cidr_block")
}

#######################
# notification Network ACLs
#######################
resource "aws_network_acl" "notification" {
  count = var.create_vpc && var.notification_dedicated_network_acl && length(var.notification_subnets) > 0 ? 1 : 0

  vpc_id     = element(aws_vpc.this[*].id, 0)
  subnet_ids = aws_subnet.notification[*].id

  tags = merge({"Name" = format("%s-${var.env}-notification-nacl", var.name)}, var.tags)
}

resource "aws_network_acl_rule" "notification_inbound" {
  count = var.create_vpc && var.notification_dedicated_network_acl && length(var.notification_subnets) > 0 ? length(var.notification_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.notification[0].id

  egress      = false
  rule_number = lookup(var.notification_inbound_acl_rules[count.index], "rule_number")
  rule_action = lookup(var.notification_inbound_acl_rules[count.index], "rule_action")
  from_port   = lookup(var.notification_inbound_acl_rules[count.index], "from_port")
  to_port     = lookup(var.notification_inbound_acl_rules[count.index], "to_port")
  protocol    = lookup(var.notification_inbound_acl_rules[count.index], "protocol")
  cidr_block  = lookup(var.notification_inbound_acl_rules[count.index], "cidr_block")
}

resource "aws_network_acl_rule" "notification_outbound" {
  count = var.create_vpc && var.notification_dedicated_network_acl && length(var.notification_subnets) > 0 ? length(var.notification_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.notification[0].id

  egress      = true
  rule_number = lookup(var.notification_outbound_acl_rules[count.index], "rule_number")
  rule_action = lookup(var.notification_outbound_acl_rules[count.index], "rule_action")
  from_port   = lookup(var.notification_outbound_acl_rules[count.index], "from_port")
  to_port     = lookup(var.notification_outbound_acl_rules[count.index], "to_port")
  protocol    = lookup(var.notification_outbound_acl_rules[count.index], "protocol")
  cidr_block  = lookup(var.notification_outbound_acl_rules[count.index], "cidr_block")
}

#######################
# captcha Network ACLs
#######################
resource "aws_network_acl" "captcha" {
  count = var.create_vpc && var.captcha_dedicated_network_acl && length(var.captcha_subnets) > 0 ? 1 : 0

  vpc_id     = element(aws_vpc.this[*].id, 0)
  subnet_ids = aws_subnet.captcha[*].id

  tags = merge({"Name" = format("%s-${var.env}-captcha-nacl", var.name)}, var.tags)
}

resource "aws_network_acl_rule" "captcha_inbound" {
  count = var.create_vpc && var.captcha_dedicated_network_acl && length(var.captcha_subnets) > 0 ? length(var.captcha_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.captcha[0].id

  egress      = false
  rule_number = lookup(var.captcha_inbound_acl_rules[count.index], "rule_number")
  rule_action = lookup(var.captcha_inbound_acl_rules[count.index], "rule_action")
  from_port   = lookup(var.captcha_inbound_acl_rules[count.index], "from_port")
  to_port     = lookup(var.captcha_inbound_acl_rules[count.index], "to_port")
  protocol    = lookup(var.captcha_inbound_acl_rules[count.index], "protocol")
  cidr_block  = lookup(var.captcha_inbound_acl_rules[count.index], "cidr_block")
}

resource "aws_network_acl_rule" "captcha_outbound" {
  count = var.create_vpc && var.captcha_dedicated_network_acl && length(var.captcha_subnets) > 0 ? length(var.captcha_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.captcha[0].id

  egress      = true
  rule_number = lookup(var.captcha_outbound_acl_rules[count.index], "rule_number")
  rule_action = lookup(var.captcha_outbound_acl_rules[count.index], "rule_action")
  from_port   = lookup(var.captcha_outbound_acl_rules[count.index], "from_port")
  to_port     = lookup(var.captcha_outbound_acl_rules[count.index], "to_port")
  protocol    = lookup(var.captcha_outbound_acl_rules[count.index], "protocol")
  cidr_block  = lookup(var.captcha_outbound_acl_rules[count.index], "cidr_block")
}


########################
# rds Network ACLs
########################
resource "aws_network_acl" "rds" {
  count = var.create_vpc && var.rds_dedicated_network_acl && length(var.rds_subnets) > 0 ? 1 : 0

  vpc_id     = element(aws_vpc.this[*].id, 0)
  subnet_ids = aws_subnet.rds[*].id

  tags = merge({"Name" = format("%s-${var.env}-rds-nacl", var.name)}, var.tags)
}

resource "aws_network_acl_rule" "rds_inbound" {
  count = var.create_vpc && var.rds_dedicated_network_acl && length(var.rds_subnets) > 0 ? length(var.rds_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.rds[0].id

  egress      = false
  rule_number = lookup(var.rds_inbound_acl_rules[count.index], "rule_number")
  rule_action = lookup(var.rds_inbound_acl_rules[count.index], "rule_action")
  from_port   = lookup(var.rds_inbound_acl_rules[count.index], "from_port")
  to_port     = lookup(var.rds_inbound_acl_rules[count.index], "to_port")
  protocol    = lookup(var.rds_inbound_acl_rules[count.index], "protocol")
  cidr_block  = lookup(var.rds_inbound_acl_rules[count.index], "cidr_block")
}

resource "aws_network_acl_rule" "rds_outbound" {
  count = var.create_vpc && var.rds_dedicated_network_acl && length(var.rds_subnets) > 0 ? length(var.rds_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.rds[0].id

  egress      = true
  rule_number = lookup(var.rds_outbound_acl_rules[count.index], "rule_number")
  rule_action = lookup(var.rds_outbound_acl_rules[count.index], "rule_action")
  from_port   = lookup(var.rds_outbound_acl_rules[count.index], "from_port")
  to_port     = lookup(var.rds_outbound_acl_rules[count.index], "to_port")
  protocol    = lookup(var.rds_outbound_acl_rules[count.index], "protocol")
  cidr_block  = lookup(var.rds_outbound_acl_rules[count.index], "cidr_block")
}


##############
# NAT Gateway
##############
locals {
  nat_gateway_ips = "${split(",", (var.reuse_nat_ips ? join(",", var.external_nat_ip_ids) : join(",", aws_eip.nat.*.id)))}"
}

resource "aws_eip" "nat" {
  count = var.create_vpc && (var.enable_nat_gateway && !var.reuse_nat_ips) ? local.nat_gateway_count : 0

  vpc = true

  # tags = merge({"Name" = format("%s-${var.env}-%s-nat-eip", var.name, element(var.azs, (var.single_nat_gateway ? 0 : count.index)))}, var.tags)
  tags = merge({"Name" = format("%s-${var.env}-%s-nat-eip", var.name, element(aws_subnet.public[*].availability_zone, (var.single_nat_gateway ? 0 : count.index)))}, var.tags)

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = var.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0

  allocation_id = element(local.nat_gateway_ips, (var.single_nat_gateway ? 0 : count.index))
  subnet_id     = element(aws_subnet.public[*].id, (var.single_nat_gateway ? 0 : count.index))

  # tags = merge({"Name" = format("%s-${var.env}-%s-nat", var.name, element(var.azs, (var.single_nat_gateway ? 0 : count.index)))}, var.tags)
  tags = merge({"Name" = format("%s-${var.env}-%s-nat", var.name, element(aws_subnet.public[*].availability_zone, (var.single_nat_gateway ? 0 : count.index)))}, var.tags)

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route" "app_nat_gateway" {
  count = var.create_vpc && length(aws_route_table.app.*.id) > 0 && var.enable_nat_gateway ? local.nat_gateway_count : 0

  route_table_id         = element(aws_route_table.app.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this.*.id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "web_nat_gateway" {
  count = var.create_vpc && length(aws_route_table.web[*].id) > 0 && var.enable_nat_gateway ? local.nat_gateway_count : 0

  route_table_id         = element(aws_route_table.web[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "notification_nat_gateway" {
  count = var.create_vpc && length(aws_route_table.notification[*].id) > 0 && var.enable_nat_gateway ? local.nat_gateway_count : 0

  route_table_id         = element(aws_route_table.notification[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "captcha_nat_gateway" {
  count = var.create_vpc && length(aws_route_table.captcha[*].id) > 0 &&var.enable_nat_gateway ? local.nat_gateway_count : 0

  route_table_id         = element(aws_route_table.captcha[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

######################
# VPC Endpoint for S3
######################
data "aws_vpc_endpoint_service" "s3" {
  count = var.create_vpc && var.enable_s3_endpoint ? 1 : 0

  service = "s3"
}

resource "aws_vpc_endpoint" "s3" {
  count = var.create_vpc && var.enable_s3_endpoint ? 1 : 0

  vpc_id       = local.vpc_id
  service_name = data.aws_vpc_endpoint_service.s3[0].service_name
}

resource "aws_vpc_endpoint_route_table_association" "app_s3" {
  count = var.create_vpc && var.enable_s3_endpoint ? local.nat_gateway_count : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = element(aws_route_table.app[*].id, count.index)
}

resource "aws_vpc_endpoint_route_table_association" "web_s3" {
  count = var.create_vpc && var.enable_s3_endpoint ? local.nat_gateway_count : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = element(aws_route_table.web[*].id, count.index)
}

resource "aws_vpc_endpoint_route_table_association" "notification_s3" {
  count = var.create_vpc && var.enable_s3_endpoint ? local.nat_gateway_count : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = element(aws_route_table.notification[*].id, count.index)
}

resource "aws_vpc_endpoint_route_table_association" "captcha_s3" {
  count = var.create_vpc && var.enable_s3_endpoint ? local.nat_gateway_count : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = element(aws_route_table.captcha[*].id, count.index)
}

resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count = var.create_vpc && var.enable_s3_endpoint && length(var.public_subnets) > 0 ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = aws_route_table.public[0].id
}


##########################
# Route table association
##########################
resource "aws_route_table_association" "app" {
  count = var.create_vpc && length(var.app_subnets) > 0 ? length(var.app_subnets) : 0

  subnet_id      = element(aws_subnet.app[*].id, count.index)
  route_table_id = element(aws_route_table.app.*.id, (var.single_nat_gateway ? 0 : count.index))
}

resource "aws_route_table_association" "web" {
  count = var.create_vpc && length(var.web_subnets) > 0 ? length(var.web_subnets) : 0

  subnet_id      = element(aws_subnet.web.*.id, count.index)
  route_table_id = element(aws_route_table.web.*.id, (var.single_nat_gateway ? 0 : count.index))
}

resource "aws_route_table_association" "notification" {
  count = var.create_vpc && length(var.notification_subnets) > 0 ? length(var.notification_subnets) : 0

  subnet_id      = element(aws_subnet.notification.*.id, count.index)
  route_table_id = element(aws_route_table.notification.*.id, (var.single_nat_gateway ? 0 : count.index))
}

resource "aws_route_table_association" "captcha" {
  count = var.create_vpc && length(var.captcha_subnets) > 0 ? length(var.captcha_subnets) : 0

  subnet_id      = element(aws_subnet.captcha.*.id, count.index)
  route_table_id = element(aws_route_table.captcha.*.id, (var.single_nat_gateway ? 0 : count.index))
}

resource "aws_route_table_association" "rds" {
  count = var.create_vpc && length(var.rds_subnets) > 0 ? length(var.rds_subnets) : 0

  subnet_id      = element(aws_subnet.rds[*].id, count.index)
  route_table_id = element(coalescelist(aws_route_table.rds.*.id, aws_route_table.app.*.id), (var.single_nat_gateway || var.create_rds_subnet_route_table ? 0 : count.index))
}

resource "aws_route_table_association" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "lb" {
  count = var.create_vpc && length(var.lb_subnets) > 0 ? length(var.lb_subnets) : 0

  subnet_id      = element(aws_subnet.lb[*].id, count.index)
  route_table_id = aws_route_table.lb[0].id
}
