output "vpc_id" {
  value = element(module.main-vpc.vpc[*].id, 0)
}

output "app_subnet_id" {
  value = module.main-vpc.app_subnets[*].id
}

output "jumpserver_subnet_id" {
  value = module.main-vpc.jumpserver_subnets[*].id
}

output "web_subnet_id" {
  value = module.main-vpc.web_subnets[*].id
}

output "notification_subnet_id" {
  value = module.main-vpc.notification_subnets[*].id
}

output "captcha_subnet_id" {
  value = module.main-vpc.captcha_subnets[*].id
}

output "lb_subnet_id" {
  value = module.main-vpc.lb_subnets[*].id
}

output "rds_subnet_id" {
  value = module.main-vpc.rds_subnets[*].id
}

output "app_server_list" {
  value = module.app-ec2.ec2_details[*].private_ip
}

output "jumpserver_static_public_ip_address" {
  value = module.jumpserver-ec2.eip[*].public_ip
}

output "web_server_list" {
  value = module.web-ec2.ec2_details[*].private_ip
}

output "notification_server_list" {
  value = module.notification-ec2.ec2_details[*].private_ip
}

output "captcha_server_list" {
  value = module.captcha-ec2.ec2_details[*].private_ip
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = module.main-alb.load_balancer.dns_name
}
#
# output "db_master_endpoint" {
#   description = "master RDS database endpoint"
#   value       = module.master_db.db_instance[*].address
# }
#
# output "db_replica_endpoint" {
#   description = "Replica RDS database endpoint"
#   value       = module.replica.db_instance[*].address
# }
