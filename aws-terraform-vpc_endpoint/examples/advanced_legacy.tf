terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 2.7"
  region  = "us-west-2"
}

locals {
  endpoint_policies = {
    s3 = {
      Version = "2012-10-17"
      Statement = [
        {
          Action    = "*"
          Effect    = "Allow"
          Resource  = "*"
          Principal = "*"
        }
      ]
    }

    ec2 = {
      Version = "2012-10-17"
      Statement = [
        {
          Action    = "*"
          Effect    = "Allow"
          Resource  = "*"
          Principal = "*"
        }
      ]
    }
  }
}

module "base_network" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=v0.12.6"

  name = "VPC-Endpoint-Test"
}

module "security_groups" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-security_group?ref=v0.12.3"

  name   = "test_sg"
  vpc_id = module.base_network.vpc_id
}

module "vpc_endpoint" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_endpoint?ref=v0.12.5"

  codebuild_endpoint_enable               = true
  codebuild_private_dns_enable            = true
  codebuild_fips_endpoint_enable          = false
  codebuild_fips_private_dns_enable       = false
  dynamo_db_endpoint_enable               = true
  ec2_endpoint_enable                     = true
  ec2_private_dns_enable                  = true
  ec2messages_endpoint_enable             = true
  ec2messages_private_dns_enable          = true
  ecr_api_endpoint_enable                 = true
  ecr_api_private_dns_enable              = true
  ecr_dkr_endpoint_enable                 = true
  ecr_dkr_private_dns_enable              = true
  elasticloadbalancing_endpoint_enable    = true
  elasticloadbalancing_private_dns_enable = true
  endpoint_policies                       = local.endpoint_policies
  events_endpoint_enable                  = true
  events_private_dns_enable               = true
  execute_api_endpoint_enable             = true
  execute_api_private_dns_enable          = true
  kinesis_streams_endpoint_enable         = true
  kinesis_streams_private_dns_enable      = true
  kms_endpoint_enable                     = true
  kms_private_dns_enable                  = true
  logs_endpoint_enable                    = true
  logs_private_dns_enable                 = true
  monitoring_endpoint_enable              = true
  monitoring_private_dns_enable           = true
  s3_endpoint_enable                      = true
  sagemaker_runtime_endpoint_enable       = true
  sagemaker_runtime_private_dns_enable    = true
  secretsmanager_endpoint_enable          = true
  secretsmanager_private_dns_enable       = true
  security_groups                         = [module.security_groups.vpc_endpoint_security_group_id]
  servicecatalog_endpoint_enable          = true
  servicecatalog_private_dns_enable       = true
  sns_endpoint_enable                     = true
  sns_private_dns_enable                  = true
  sqs_endpoint_enable                     = true
  sqs_private_dns_enable                  = true
  ssm_endpoint_enable                     = true
  ssm_private_dns_enable                  = true
  subnets                                 = module.base_network.private_subnets
  vpc_id                                  = module.base_network.vpc_id

  route_tables = concat(
    module.base_network.private_route_tables,
    module.base_network.public_route_tables,
  )
}
