module "main-sg" {
  source = "./modules/security_group/"

  name    = var.name
  env = var.env
  tags_sg = var.tags

  create_sg = true

  vpc-id = element(module.main-vpc.vpc[*].id, 0)

  jumpserver_ingress_rules = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH connections from internet"
    },
    {
      cidr_blocks = ["13.126.151.121/32"]
      from_port   = 5666
      to_port     = 5666
      protocol    = "tcp"
      description = "Allow gmetrics monitoring connections from monitoring server"
    },
    {
      cidr_blocks = ["13.126.151.121/32"]
      from_port   = 5667
      to_port     = 5667
      protocol    = "tcp"
      description = "Allow gmetrics monitoring connections from monitoring server"
    },
    {
      cidr_blocks = ["13.126.151.121/32"]
      from_port   = 5668
      to_port     = 5668
      protocol    = "tcp"
      description = "Allow gmetrics monitoring connections from monitoring server"
    },
    {
      cidr_blocks = ["13.126.151.121/32"]
      from_port   = 5669
      to_port     = 5669
      protocol    = "tcp"
      description = "Allow gmetrics monitoring connections from monitoring server"
    },
    {
      cidr_blocks = ["13.126.151.121/32"]
      from_port   = 5670
      to_port     = 5670
      protocol    = "tcp"
      description = "Allow gmetrics monitoring connections from monitoring server"
    },
  ]

  lb_ingress_rules = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP connections from internet"
    },
    {
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS connections from internet"
    },
  ]

  app_ingress_rules = [
    {
      cidr_blocks = var.jumpserver_subnets
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH connections from Management Resources"
    },
     {
      cidr_blocks = var.jumpserver_subnets
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
      description = "Allow app connections from jumpserver Resources"
    },
    {
      cidr_blocks = var.jumpserver_subnets
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP connections from jumpserver Resources"
    },

     {
      cidr_blocks = var.lb_subnets
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP connections from Load Balancer"
    },
      {
      cidr_blocks = var.lb_subnets
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
      description = "Allow app connections from Load Balancer"
    },
    {
      cidr_blocks = var.web_subnets
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
      description = "Allow web connections from webserver"
    },
     {
      cidr_blocks = ["10.0.91.189/32"]
      from_port   = 5666
      to_port     = 5666
      protocol    = "tcp"
      description = "Allow gmetrics monitoring connections from jumpserver"
    },


  ]

  rds_ingress_rules = [
    {
      cidr_blocks = concat(
        var.app_subnets,
        var.jumpserver_subnets,
        var.notification_subnets,
      )
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Allow db connections from Application, JumpServer Resources"
    },
  ]

  web_ingress_rules = [
    {
      cidr_blocks = var.jumpserver_subnets
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH connections from JumpServer Resources"
    },
    {
      cidr_blocks = var.lb_subnets
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP connections from Load Balancer"
    },
      {
      cidr_blocks = var.jumpserver_subnets
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP connections from JumpServer Resources"
    },
    {
      cidr_blocks = ["10.0.91.189/32"]
      from_port   = 5666
      to_port     = 5666
      protocol    = "tcp"
      description = "Allow gmetrics monitoring connections from jumpserver"
    },
  ]

  notification_ingress_rules = [
    {
      cidr_blocks = var.jumpserver_subnets
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH connections from JumpServer Resources"
    },
    {
      cidr_blocks = var.app_subnets
      from_port   = 5672
      to_port     = 5672
      protocol    = "tcp"
      description = "Allow connections from App Subnet"
    },
    {
      cidr_blocks = var.app_subnets
      from_port   = 5678
      to_port     = 5678
      protocol    = "tcp"
      description = "Allow connections from App Subnet"
    },
     {
      cidr_blocks = var.notification_subnets
      from_port   = 5672
      to_port     = 5672
      protocol    = "tcp"
      description = "Allow connections from notification Subnet"
    },

    {
      cidr_blocks = ["10.0.91.189/32"]
      from_port   = 5666
      to_port     = 5666
      protocol    = "tcp"
      description = "Allow gmetrics monitoring connections from jumpserver"
    },

  ]

  job_ingress_rules = [
    {
      cidr_blocks = var.jumpserver_subnets
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH connections from JumpServer Resources"
    },
    {
      cidr_blocks = var.app_subnets
      from_port   = 5672
      to_port     = 5672
      protocol    = "tcp"
      description = "Allow connections from App Subnet"
    },
  ]

  captcha_ingress_rules = [
    {
      cidr_blocks = var.jumpserver_subnets
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH connections from JumpServer Resources"
    },
    {
      cidr_blocks = var.app_subnets
      from_port   = 8280
      to_port     = 8280
      protocol    = "tcp"
      description = "Allow connections from App Subnet"
    },
  ]

}
