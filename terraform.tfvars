# Mandatory - Name of the application
name = "bigfish"

# Mandatory - name of the application environment
env = "Prod"

# Mandatory - AWS region when resouces should be created
AWS_REGION = "ap-south-1"

# Mandatory - Name to be used on all resources as prefix
tags = {"Terraform" = "true"}

# CIDR for VPC
vpc_cidr = "10.0.0.0/16"

# CIDR for app subnets
app_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

# CIDR for web subnets
web_subnets = ["10.0.10.0/24"]

# CIDR for notification subnets
notification_subnets = ["10.0.15.0/24"]

# CIDR for Captcha subnets
captcha_subnets = ["10.0.16.0/24"]

# CIDR for rds subnets
rds_subnets = ["10.0.21.0/24", "10.0.22.0/24"]

# CIDR for Load balancer subnets
lb_subnets = ["10.0.61.0/24", "10.0.62.0/24"]

# CIDR for jumserver subnets
jumpserver_subnets = ["10.0.91.0/24"]

# Create a new key for logging in to the instance. Allowed values true/false
create_new_key_pair = true

# If create_new_key_pair is true, provide public key file.
ssh_key_filename = "~/.ssh/bigfish-Prod-key.pub"

# If create_new_key_pair is false, provide existing key pair name here.
# key_pair_existing = "key-pair-name-already-available"

# If create_new_key_pair is true, provide new key pair name here.
ssh_key_pair_name = "bigfish-Prod-key"

# Number of instances to launch
app_instance_count = 2

# ID of AMI to use for the instance. Default is Ubuntu 18.04 Bionic amd64
app_ami =  "ami-0620d12a9cf777c87"

# The type of instance to start
app_instance_type = "t2.small"

# Suffix to append to instance name
app_instance_suffix = "app"

# Size of data partiton in GiB
app_root_volume_size = "10"

# Size of data partiton in GiB
app_data_volume_size = "10"

# Number of instances to launch
web_instance_count = 1

# ID of AMI to use for the instance. Default is Ubuntu 18.04 Bionic amd64
web_ami =  "ami-0620d12a9cf777c87"

# The type of instance to start
web_instance_type = "t2.micro"

# Suffix to append to instance name
# web_instance_suffix = "web"

# Size of data partiton in GiB
web_root_volume_size = "10"

# Size of data partiton in GiB
web_data_volume_size = "10"

# Number of instances to launch
jumpserver_instance_count = 1

# ID of AMI to use for the instance. Default is Ubuntu 18.04 Bionic amd64
jumpserver_ami =  "ami-0620d12a9cf777c87"

# The type of instance to start
jumpserver_instance_type = "t2.micro"

# Suffix to append to instance name
# jumpserver_instance_suffix = "jumpserver"

# Size of data partiton in GiB
jumpserver_root_volume_size = "10"

# Size of data partiton in GiB
jumpserver_data_volume_size = "10"

# Number of Notification instances to launch
notification_instance_count = 1

# ID of AMI to use for the instance. Default is Ubuntu 18.04 Bionic amd64
notification_ami =  "ami-0620d12a9cf777c87"

# The type of instance to start
notification_instance_type = "t2.small"

# Suffix to append to instance name
# notification_instance_suffix = "notification"

# Size of data partiton in GiB
notification_root_volume_size = "10"

# Size of data partiton in GiB
notification_data_volume_size = "10"

# Number of Notification instances to launch
job_instance_count = 1

# ID of AMI to use for the instance. Default is Ubuntu 18.04 Bionic amd64
job_ami =  "ami-0620d12a9cf777c87"

# The type of instance to start
job_instance_type = "t2.small"

# Suffix to append to instance name
# job_instance_suffix = "notification"

# Size of data partiton in GiB
job_root_volume_size = "10"

# Size of data partiton in GiB
job_data_volume_size = "10"

# Number of instances to launch
captcha_instance_count = 1

# ID of AMI to use for the instance. Default is Ubuntu 18.04 Bionic amd64
captcha_ami =  "ami-0620d12a9cf777c87"

# The type of instance to start
captcha_instance_type = "t2.micro"

# Suffix to append to instance name
# captcha_instance_suffix = "captcha"

# Size of data partiton in GiB
captcha_root_volume_size = "10"

# Size of data partiton in GiB
# captcha_data_volume_size = "10"

# DB engine
# db_engine = "mysql"

# The rails database adapter for the generated database.yml file
# rails_db_adapter = "mysql2"

# DB Version
# db_version = "5.6.40"

# DB instance type
# db_instance_type = "db.t2.large"

# DB Instance Storage size
# db_storage = 5

# One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD). The default is 'io1' if iops is specified, 'standard' if not. Note that this behaviour is different from the AWS web console, where the default is 'gp2'.
# db_storage_type = "gp2"

# Number if disk iops if io1 is the db_storage_type
# db_iops = 0

# Database Name
database_name =  "testdb"

# Database user or admin user
database_user =  "dbadmin"

# Database user/admin user password
database_passwd =  "hello123"

# DB Port Number
# database_port = "3306"

# Name of the database master instance to be created
master_db_identifier =  "master"

# Name of the database replica instance to be created
replica_db_identifier =  "replica"

# Whether the database should be automatically upgraded to the latest minor version
# auto_minor_version_upgrade = false

# Whether the replica database should be automatically upgraded to the latest minor version
# replica_auto_minor_version_upgrade = false

# A map of DB parameter options to apply For eg: pgroup_parameters = { character_set_server = utf8 }
# db_parameters = {}

# Whether the instance will allow itself to be deleted
# deletion_protection = true

# The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh:24mi'. Eg: 'Mon:00:00-Mon:03:00'
# maintenance_window = "Mon:00:05-Mon:03:00"

# The days to retain backups for
# master_backup_retention_period = 7

# The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenance_window
# backup_window = "03:00-05:00"

# Enable https traffic
enable_https = true

#Certificate .crt file path
cert_crt_file_path = "./certs/server.crt"

# Certificate .key file path
cert_key_file_path = "./certs/server.key"

# Certificate .chain file path
cert_chain_file_path = "../certs/server.chain"
