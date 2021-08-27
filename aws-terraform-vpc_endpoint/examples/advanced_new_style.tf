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

# `dynamo_db_endpoint_enable` and `s3_endpoint_enable` must explicitly be set to false  when we
# choose to use the new style implementation as the default is `true` for those variables.
# If not disabled, a collision will occur.
module "vpc_endpoint" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_endpoint?ref=v0.12.5"

  dynamo_db_endpoint_enable = false
  enable_private_dns_list   = ["codebuild", "ec2", "ec2messages", "elasticloadbalancing", "ecr.api", "ecr.dkr", "events", "kms", "logs", "monitoring", "sagemaker.runtime", "secretsmanager", "servicecatalog", "sns", "sqs", "ssm"]
  endpoint_policies         = local.endpoint_policies
  gateway_endpoints         = ["s3", "dynamodb"]
  interface_endpoints       = ["codebuild", "ec2", "ec2messages", "elasticloadbalancing", "ecr.api", "ecr.dkr", "events", "execute-api", "kinesis-streams", "kms", "logs", "monitoring", "sagemaker.runtime", "secretsmanager", "servicecatalog", "sns", "sqs", "ssm"]
  security_groups           = [module.security_groups.vpc_endpoint_security_group_id]
  subnets                   = module.base_network.private_subnets
  s3_endpoint_enable        = false
  vpc_id                    = module.base_network.vpc_id

  route_tables = concat(
    module.base_network.private_route_tables,
    module.base_network.public_route_tables,
  )
}
