module "main-alb" {
  source = "./modules/loadbalancer/"

  name = var.name
  env = var.env
  tags = merge(var.tags, {"Environment" = var.env})

  vpc_id          = element(module.main-vpc.vpc[*].id, 0)
  security_groups = module.main-sg.lb_sg[*].id
  subnets         = module.main-vpc.lb_subnets[*].id

  enable_https = var.enable_https

  cert_crt_file_path   = var.cert_crt_file_path
  cert_key_file_path   = var.cert_key_file_path
  # cert_chain_file_path = var.cert_chain_file_path

  web_http_target_group = {
      name              = "web-prod-http-target-group"
      backend_protocol  = "HTTP"
      backend_port      = 80
      health_check_path = "/index.html"
    }

  app_http_target_group = {
      name              = "app-prod-http-targets-group"
      backend_protocol  = "HTTP"
      backend_port      = 5000
      health_check_path = "/bigfishserver/"
    }

#  web_https_target_group = {
#      name             = "web-https-target-group"
#      backend_port     = 443
#      backend_protocol = "HTTPS"
#    }

#  app_https_target_group = {
#      name             = "app-https-target-group"
#      backend_port     = 443
#      backend_protocol = "HTTPS"
#    }

  http_tcp_listeners = [
    {
      port     = 80
      protocol = "HTTP"
    },
  ]

  https_listeners = [
    {
      port     = 443
      protocol = "HTTPS"
    },
  ]

  web_target_ids = module.web-ec2.ec2_details[*].id
  app_target_ids = module.app-ec2.ec2_details[*].id

}
