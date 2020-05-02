# Default Options

variable "name" {
  description = "Mandatory - Name of the application"
  default     = "bigfish"
}

variable "env" {
  description = "Mandatory - name of the application environment"
  default     = "test"
}

variable "AWS_REGION" {
  description = "Mandatory - AWS region when resouces should be created"
  default     = "ap-south-1"
}

variable "tags" {
  description = "Mandatory - Name to be used on all resources as prefix"
  default = {
    Terraform  = "true"
  }
}

#### VPC VARIABLES #########

variable "vpc_cidr" {
  description = "CIDR for VPC"
  default     = "10.0.0.0/16"
}

variable "app_subnets" {
  description = "CIDR for app subnets"
  type = list(string)
  default     = ["10.0.1.0/24","10.0.2.0/24"]
}

variable "web_subnets" {
  description = "CIDR for web subnets"
  type = list(string)
  default     = ["10.0.10.0/24","10.0.11.0/24"]
}

variable "notification_subnets" {
  description = "CIDR for notification subnets"
  type = list(string)
  default     = ["10.0.15.0/24"]
}

variable "captcha_subnets" {
  description = "CIDR for Captcha subnets"
  type = list(string)
  default     = ["10.0.16.0/24"]
}

variable "rds_subnets" {
  description = "CIDR for rds subnets"
  type = list(string)
  default     = ["10.0.21.0/24","10.0.22.0/24"]
}

variable "lb_subnets" {
  description = "CIDR for Load balancer subnets"
  type = list(string)
  default     = ["10.0.61.0/24","10.0.62.0/24"]
}

variable "jumpserver_subnets" {
  description = "CIDR for jumserver subnets"
  type = list(string)
  default     = ["10.0.91.0/24"]
}

# SSH KEY

variable "create_new_key_pair" {
  description = "Create a new key for logging in to the instance. Allowed values true/false"
  default     = false
}

variable "ssh_key_filename" {
  description = "If create_new_key_pair is true, provide public key file."
  default     = "~/.ssh/id_rsa.pub"
}

variable "key_pair_existing" {
  description = "If create_new_key_pair is false, provide existing key pair name here."
  default     = "key-pair-name-already-available"
}

variable "ssh_key_pair_name" {
  description = "If create_new_key_pair is true, provide new key pair name here."
  default     = "new-key-pair-name"
}

# APP Instance Profile

variable "app_instance_count" {
  description = "Number of instances to launch"
  default     = 1
}

variable "app_ami" {
  description = "ID of AMI to use for the instance. Default is Ubuntu 18.04 Bionic amd64"
}

variable "app_instance_type" {
  description = "The type of instance to start"
  default     = "t2.micro"
}

variable "app_instance_suffix" {
  description = "Suffix to append to instance name"
  default     = "app"
}

variable "app_root_volume_size" {
  description = "Size of data partiton in GiB"
  default     = "10"
}

variable "app_data_volume_size" {
  description = "Size of data partiton in GiB"
  default     = "10"
}

# Web Instance Profile

variable "web_instance_count" {
  description = "Number of instances to launch"
  default     = 1
}

variable "web_ami" {
  description = "ID of AMI to use for the instance. Default is Ubuntu 18.04 Bionic amd64"
}

variable "web_instance_type" {
  description = "The type of instance to start"
  default     = "t2.micro"
}

variable "web_instance_suffix" {
  description = "Suffix to append to instance name"
  default     = "web"
}

variable "web_root_volume_size" {
  description = "Size of data partiton in GiB"
  default     = "10"
}

variable "web_data_volume_size" {
  description = "Size of data partiton in GiB"
  default     = "10"
}

# JumpServer Instance Profile

variable "jumpserver_instance_count" {
  description = "Number of instances to launch"
  default     = 1
}

variable "jumpserver_ami" {
  description = "ID of AMI to use for the instance. Default is Ubuntu 18.04 Bionic amd64"
}

variable "jumpserver_instance_type" {
  description = "The type of instance to start"
  default     = "t2.micro"
}

variable "jumpserver_instance_suffix" {
  description = "Suffix to append to instance name"
  default     = "jumpserver"
}

variable "jumpserver_root_volume_size" {
  description = "Size of data partiton in GiB"
  default     = "10"
}

variable "jumpserver_data_volume_size" {
  description = "Size of data partiton in GiB"
  default     = "10"
}

# Notification Instance Profile

variable "notification_instance_count" {
  description = "Number of Notification instances to launch"
  default     = 1
}

variable "notification_ami" {
  description = "ID of AMI to use for the instance. Default is Ubuntu 18.04 Bionic amd64"
}

variable "notification_instance_type" {
  description = "The type of instance to start"
  default     = "t2.micro"
}

variable "notification_instance_suffix" {
  description = "Suffix to append to instance name"
  default     = "notification"
}

variable "notification_root_volume_size" {
  description = "Size of data partiton in GiB"
  default     = "10"
}

variable "notification_data_volume_size" {
  description = "Size of data partiton in GiB"
  default     = "10"
}

# Job Instance Profile

variable "job_instance_count" {
  description = "Number of job instances to launch"
  default     = 1
}

variable "job_ami" {
  description = "ID of AMI to use for the instance. Default is Ubuntu 18.04 Bionic amd64"
}

variable "job_instance_type" {
  description = "The type of instance to start"
  default     = "t2.micro"
}

variable "job_instance_suffix" {
  description = "Suffix to append to instance name"
  default     = "job"
}

variable "job_root_volume_size" {
  description = "Size of data partiton in GiB"
  default     = "10"
}

variable "job_data_volume_size" {
  description = "Size of data partiton in GiB"
  default     = "10"
}


# Captcha Instance Profile

variable "captcha_instance_count" {
  description = "Number of instances to launch"
  default     = 1
}

variable "captcha_ami" {
  description = "ID of AMI to use for the instance. Default is Ubuntu 18.04 Bionic amd64"
}

variable "captcha_instance_type" {
  description = "The type of instance to start"
  default     = "t2.micro"
}

variable "captcha_instance_suffix" {
  description = "Suffix to append to instance name"
  default     = "captcha"
}

variable "captcha_root_volume_size" {
  description = "Size of data partiton in GiB"
  default     = "10"
}

variable "captcha_data_volume_size" {
  description = "Size of data partiton in GiB"
  default     = "10"
}

# ### DATABASE VARIABLES ###

variable "db_engine" {
  description = "DB engine"
  default = "mysql"
}

variable "rails_db_adapter" {
  description = "The rails database adapter for the generated database.yml file"
  default = "mysql2"
}

variable "db_version" {
  description = "DB Version"
  default     = "5.6.40"
}

variable "db_instance_type" {
  description = "DB instance type"
  default     = "db.t2.large"
}

variable "db_storage" {
  description = "DB Instance Storage size"
  default     = 5
}

variable "db_storage_type" {
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD). The default is 'io1' if iops is specified, 'standard' if not. Note that this behaviour is different from the AWS web console, where the default is 'gp2'."
  default     = "gp2"
}

variable "db_iops" {
  description = "Number if disk iops if io1 is the db_storage_type"
  default = 0
}

variable "database_name" {
  description = "Database Name"
}

variable "database_user" {
  description = "Database user or admin user"
}

variable "database_passwd" {
  description = "Database user/admin user password"
}

variable "database_port" {
  description = "DB Port Number"
  default     = "3306"
}

variable "master_db_identifier" {
  description = "Name of the database master instance to be created"
}

variable "replica_db_identifier" {
  description = "Name of the database replica instance to be created"
}

variable "auto_minor_version_upgrade" {
  description = "Whether the database should be automatically upgraded to the latest minor version"
  default = false
}

variable "replica_auto_minor_version_upgrade" {
  description = "Whether the replica database should be automatically upgraded to the latest minor version"
  default = false
}

variable "db_parameters" {
  description = "A map of DB parameter options to apply For eg: pgroup_parameters = { character_set_server = utf8 }"
  type = map
  default     = {}
}

variable "deletion_protection" {
  description = "Whether the instance will allow itself to be deleted"
  default = true
}

variable "maintenance_window" {
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh:24mi'. Eg: 'Mon:00:00-Mon:03:00'"
  default = "Mon:00:05-Mon:03:00"
}

variable "master_backup_retention_period" {
  description = "The days to retain backups for"
  default = 7
}

variable "backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenance_window"
  default = "03:00-05:00"
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values (depending on engine): alert, audit, error, general, listener, slowquery, trace, postgresql (PostgreSQL), upgrade (PostgreSQL)."
  default     = []
}

# Load Balancer

variable "enable_https" {
  description = "Enable https traffic"
  default     = true
}

variable "cert_crt_file_path" {
  description = "Certificate .crt file path"
  default     = "./certs/server.crt"
}

variable "cert_key_file_path" {
  description = "Certificate .key file path"
  default     = "./certs/server.key"
}

variable "cert_chain_file_path" {
  description = "Certificate .chain file path"
  default     = "./certs/server.chain"
}
