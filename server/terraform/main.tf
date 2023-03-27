provider "aws" {
  region = "us-west-2"
}

data "aws_region" "current" {}

locals {
  app_name = "flask-app"
}

module "vpc" {
  source = "./vpc"
}

module "rds" {
  source = "./rds"

  vpc_id = module.vpc.vpc_id
  app_name = local.app_name
}

module "ec2" {
  source = "./ec2"

  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnets[0]
  app_name  = local.app_name
}

module "alb" {
  source = "./alb"

  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  target_group_arn = module.ec2.target_group_arn
  app_name        = local.app_name
}

module "apigateway" {
  source = "./apigateway"

  alb_dns_name = module.alb.alb_dns_name
  app_name     = local.app_name
}

output "api_gateway_healthcheck_url" {
  value = module.apigateway.api_gateway_url
}
