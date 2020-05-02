resource "aws_key_pair" "key_pair" {
  count      = var.create_new_key_pair ? 1 : 0
  key_name   = var.ssh_key_pair_name
  public_key = file(var.ssh_key_filename)
}

module "app-ec2" {
  source = "./modules/instances/"

  instance_count = var.app_instance_count
  ami            = var.app_ami
  instance_type  = var.app_instance_type
  subnet_ids     = module.main-vpc.app_subnets[*].id
  az_ids         = module.main-vpc.azs

  vpc_security_group_ids = module.main-sg.app_sg[*].id

  iam_instance_profile = aws_iam_instance_profile.ec2_monitoring_profile.name

  required_data_partition = false

  required_fixed_public_ip = false

  associate_public_ip_address          = false
  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"

  name = var.name
  env = var.env
  ec2_suffix = var.app_instance_suffix

  root_volume_size = var.app_root_volume_size
  data_volume_size = var.app_data_volume_size

  key_pair_name = var.create_new_key_pair ? element(concat(aws_key_pair.key_pair.*.key_name, [""]), 0) : var.key_pair_existing

  tags = merge(var.tags, {"Environment" = var.env})
}

# # web Instances
module "web-ec2" {
  source = "./modules/instances/"

  instance_count = var.web_instance_count
  ami            = var.web_ami
  instance_type  = var.web_instance_type
  subnet_ids     = module.main-vpc.web_subnets[*].id
  az_ids         = module.main-vpc.azs

  vpc_security_group_ids = module.main-sg.web_sg[*].id

  iam_instance_profile = aws_iam_instance_profile.ec2_monitoring_profile.name

  required_data_partition = false

  required_fixed_public_ip = false

  associate_public_ip_address          = false
  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"

  name = var.name
  env = var.env
  ec2_suffix = var.web_instance_suffix

  root_volume_size = var.web_root_volume_size
  data_volume_size = var.web_data_volume_size

  key_pair_name = var.create_new_key_pair ? element(concat(aws_key_pair.key_pair.*.key_name, [""]), 0) : var.key_pair_existing

  tags = merge(var.tags, {"Environment" = var.env})
}

# # Notification Instances
module "notification-ec2" {
  source = "./modules/instances/"

  instance_count = var.notification_instance_count
  ami            = var.notification_ami
  instance_type  = var.notification_instance_type
  subnet_ids     = module.main-vpc.notification_subnets[*].id
  az_ids         = module.main-vpc.azs

  vpc_security_group_ids = module.main-sg.notification_sg[*].id

  iam_instance_profile = aws_iam_instance_profile.ec2_monitoring_profile.name

  required_data_partition = false

  required_fixed_public_ip = false

  associate_public_ip_address          = false
  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"

  name = var.name
  env = var.env
  ec2_suffix = var.notification_instance_suffix

  root_volume_size = var.notification_root_volume_size
  data_volume_size = var.notification_data_volume_size

  key_pair_name = var.create_new_key_pair ? element(concat(aws_key_pair.key_pair.*.key_name, [""]), 0) : var.key_pair_existing

  tags = merge(var.tags, {"Environment" = var.env})
}

# # job Instances
module "job-ec2" {
  source = "./modules/instances/"

  instance_count = var.job_instance_count
  ami            = var.job_ami
  instance_type  = var.job_instance_type
  subnet_ids     = module.main-vpc.notification_subnets[*].id
  az_ids         = module.main-vpc.azs

  vpc_security_group_ids = module.main-sg.job_sg[*].id

  iam_instance_profile = aws_iam_instance_profile.ec2_monitoring_profile.name

  required_data_partition = false

  required_fixed_public_ip = false

  associate_public_ip_address          = false
  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"

  name = var.name
  env = var.env
  ec2_suffix = var.job_instance_suffix

  root_volume_size = var.job_root_volume_size
  data_volume_size = var.job_data_volume_size

  key_pair_name = var.create_new_key_pair ? element(concat(aws_key_pair.key_pair.*.key_name, [""]), 0) : var.key_pair_existing

  tags = merge(var.tags, {"Environment" = var.env})
}


# # captcha Instances
module "captcha-ec2" {
  source = "./modules/instances/"

  instance_count = var.captcha_instance_count
  ami            = var.captcha_ami
  instance_type  = var.captcha_instance_type
  subnet_ids     = module.main-vpc.captcha_subnets[*].id
  az_ids         = module.main-vpc.azs

  vpc_security_group_ids = module.main-sg.captcha_sg[*].id

  iam_instance_profile = aws_iam_instance_profile.ec2_monitoring_profile.name

  required_data_partition = false

  required_fixed_public_ip = false

  associate_public_ip_address          = false
  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"

  name = var.name
  env = var.env
  ec2_suffix = var.captcha_instance_suffix

  root_volume_size = var.captcha_root_volume_size
  data_volume_size = var.captcha_data_volume_size

  key_pair_name = var.create_new_key_pair ? element(concat(aws_key_pair.key_pair.*.key_name, [""]), 0) : var.key_pair_existing

  tags = merge(var.tags, {"Environment" = var.env})
}

# JumpServer Instances
module "jumpserver-ec2" {
  source = "./modules/instances/"

  instance_count = var.jumpserver_instance_count
  ami            = var.jumpserver_ami
  instance_type  = var.jumpserver_instance_type
  subnet_ids     = module.main-vpc.jumpserver_subnets[*].id
  # az_ids         = module.main-vpc.azs
  az_ids         = module.main-vpc.jumpserver_subnets[*].availability_zone

  vpc_security_group_ids = module.main-sg.jumpserver_sg[*].id

  iam_instance_profile = aws_iam_instance_profile.ec2_monitoring_profile.name

  required_data_partition = false

  required_fixed_public_ip = true

  associate_public_ip_address          = true
  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"

  name = var.name
  env = var.env
  ec2_suffix = var.jumpserver_instance_suffix

  root_volume_size = var.jumpserver_root_volume_size
  data_volume_size = var.jumpserver_data_volume_size

  key_pair_name = var.create_new_key_pair ? element(concat(aws_key_pair.key_pair.*.key_name, [""]), 0) : var.key_pair_existing

  tags = merge(var.tags, {"Environment" = var.env})
}
