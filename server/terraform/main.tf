variable "region" {
  default = "us-east-1"
}

variable "db_url" {
  type = string
  description = "The database url"
}

variable "openai_api_key" {
  type = string
  description = "The OpenAI API key"
}

variable "pinecone_api_key" {
  type = string
  description = "The Pinecone API key"
}

provider "aws" {
  region = var.region
}

locals {
  app_name = "qa-gpt"
}

module "vpc" {
  source = "./vpc"
  app_name = local.app_name
  region       = var.region
}

module "ec2" {
  source    = "./ec2"
  vpc_id    = module.vpc.vpc_id
  # subnet_id = module.vpc.subnet_id
  subnet_id = module.vpc.public_subnet_ids[0]
  public_subnet_id = module.vpc.public_subnet_ids[0]
  app_name  = local.app_name
  public_key_path = "~/.ssh/id_ed25519.pub"
  db_url = var.db_url
  openai_api_key = var.openai_api_key
  pinecone_api_key = var.pinecone_api_key
 
  depends_on = [
    module.vpc
  ]
}

# module "rds" {
#   source   = "./rds"
#   vpc_id   = module.vpc.vpc_id
#   app_name = local.app_name
#   private_subnet_ids = module.vpc.private_subnet_ids
#   app_sg_id = module.ec2.security_group_id
#   depends_on = [
#     module.ec2
#     ]
# }

# module "alb" {
#   source     = "./alb"
#   vpc_id     = module.vpc.vpc_id
#   app_name   = local.app_name
#   public_subnet_ids = module.vpc.public_subnet_ids
#   depends_on = [module.ec2]
# }

# module "api_gateway" {
#   source       = "./api_gateway"
#   app_name     = local.app_name
#   alb_dns_name = module.alb.alb_dns_name
#   region       = var.region
#   depends_on   = [module.alb]
# }

# output "alb_dns_name" {
#   value = module.alb.alb_dns_name
#   depends_on = [
#     module.alb
#   ]
# }

output "ec2_public_ip" {
  description = "The public IP address of the bastion host"
  value       = module.ec2.ec2_public_ip
}

resource "aws_eip" "eip_qa_gpt" {
  vpc = true
  instance = aws_instance.main.id 
  depends_on = [aws_instance.main]
}

# output "bastion_public_ip" {
#   description = "The public IP address of the bastion host"
#   value       = module.ec2.bastion_public_ip
# }

# output "api_gateway_healthcheck_url" {
#   value = module.api_gateway.api_gateway_healthcheck_url
#   depends_on = [
#     module.api_gateway
#   ]
# }
