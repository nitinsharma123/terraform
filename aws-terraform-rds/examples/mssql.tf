terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 2.7"
  region  = "us-east-1"
}

# this is for example purposes, please use best practice for secret storage in a production environment
resource "random_string" "password" {
  length      = 16
  min_numeric = 1
  min_lower   = 1
  min_upper   = 1
  special     = false
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=v0.12.1"

  name = "Test1VPC"
}

module "rds_mssql" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-rds?ref=v0.12.8"

  ##################
  # Required Configuration
  ##################

  engine          = "sqlserver-se"                #  Required
  instance_class  = "db.m4.large"                 #  Required
  name            = "sample-mssql-rds"            #  Required
  password        = random_string.password.result #  Required - see usage warning at top of file
  security_groups = [module.vpc.default_sg]       #  Required
  subnets         = module.vpc.private_subnets    #  Required
  # username      = "dbadmin"

  ##################
  # VPC Configuration
  ##################

  # create_subnet_group   = true
  # existing_subnet_group = "some-subnet-group-name"

  ##################
  # Microsoft Directory Service
  ##################

  # enable_domain_join = true
  # directory_id       = module.msad.id


  ##################
  # Backups and Maintenance
  ##################

  # backup_retention_period = 35
  # backup_window           = "05:00-06:00"
  # db_snapshot_id          = "some-snapshot-id"
  # maintenance_window      = "Sun:07:00-Sun:08:00"

  ##################
  # Basic RDS
  ##################

  # copy_tags_to_snapshot = true
  # dbname                = "mydb"
  # engine_version        = "14.00.3015.40.v1"
  # port                  = "1433"
  # storage_iops          = 0
  # storage_size          = 100
  # storage_type          = "gp2"
  # timezone              = "US/Central"

  ##################
  # RDS Advanced
  ##################

  # auto_minor_version_upgrade    = true
  # create_option_group           = true
  # create_parameter_group        = true
  # existing_option_group_name    = "some-option-group-name"
  # existing_parameter_group_name = "some-parameter-group-name"
  # family                        = "sqlserver-se-14.00"
  # kms_key_id                    = "some-kms-key-id"
  # multi_az                      = false
  # options                       = []
  # parameters                    = []
  # publicly_accessible           = false
  # storage_encrypted             = false

  ##################
  # RDS Monitoring
  ##################

  # alarm_cpu_limit          = 60
  # alarm_free_space_limit   = 1024000000
  # alarm_read_iops_limit    = 100
  # alarm_write_iops_limit   = 100
  # existing_monitoring_role = ""
  # monitoring_interval      = 0
  # notification_topic       = "arn:aws:sns:<region>:<account>:some-topic"

  ##################
  # Other parameters
  ##################

  # environment = "Production"

  # tags = {
  #   SomeTag = "SomeValue"
  # }
}
