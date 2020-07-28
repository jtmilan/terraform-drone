locals {
  keypair_name                       = aws_key_pair.ci_tool.key_name
  rpc_secret                         = random_string.drone_rpc_secret.result
  fqdn                               = "${var.ci_sub_domain}.${var.root_domain}"
  private_subnets                    = module.vpc.private_subnets
  public_subnets                     = module.vpc.public_subnets
  vpc_id                             = module.vpc.vpc_id
  vpc_arn                            = module.vpc.vpc_arn
  ci_server_app_security_group_id    = module.ci_server.ci_server_security_group_id
  cluster_instance_security_group_id = module.ci_ecs_cluster.instance_security_group_id
  server_log_group_arn               = module.ci_server.drone_server_log_group_arn
  agent_log_group_arn                = module.build_agent.drone_agent_log_group_arn
  rpc_server_url                     = module.ci_server.rpc_server_url
  cluster_id                         = module.ci_ecs_cluster.id
  cluster_name                       = module.ci_ecs_cluster.name
  cluster_arn                        = module.ci_ecs_cluster.arn
  db_host_name                       = module.ci_db.address
  db_user                            = module.ci_db.user
  db_password                        = module.ci_db.root_password
  db_engine                          = module.ci_db.engine
  db_port                            = module.ci_db.port
  ci_server_service_name             = module.ci_server.service_name
  drone_secrets_shared_secret        = module.ci_server.drone_secrets_shared_secret
  drone_secrets_url                  = module.ci_server.drone_secrets_url
}

resource "random_string" "drone_rpc_secret" {
  length  = 32
  special = false
}

resource "aws_key_pair" "ci_tool" {
  key_name   = "ci-tools"
  public_key = var.keypair_public_key
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> v2.0"
  name    = local.fqdn
  cidr    = var.vpc_cidr

  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  # assign_generated_ipv6_cidr_block = true
  enable_nat_gateway               = true
  single_nat_gateway               = true
  enable_dns_hostnames             = true
  enable_dns_support               = true
  public_subnet_tags = {
    Name = local.fqdn
  }

  tags = {
    Name = local.fqdn
  }

  vpc_tags = {
    Name = local.fqdn
  }
}

module "ci_db" {
  source                          = "./modules/database"
  vpc_id                          = local.vpc_id
  public_subnets                  = local.public_subnets
  private_subnets                 = local.private_subnets
  ci_server_app_security_group_id = local.ci_server_app_security_group_id
  fqdn                            = local.fqdn
  db_identifier                   = var.db_identifier
  db_storage                      = var.db_storage_size
  db_instance_class               = var.db_instance_type
  db_name                         = var.db_name
  db_username                     = var.db_user
}

module "ci_ecs_cluster" {
  source                         = "./modules/cluster"
  server_log_group_arn           = local.server_log_group_arn
  agent_log_group_arn            = local.agent_log_group_arn
  vpc_id                         = local.vpc_id
  public_subnets                 = local.public_subnets
  private_subnets                = local.private_subnets
  keypair_name                   = local.keypair_name
  fqdn                           = local.fqdn
  aws_region                     = var.aws_region
  default_instance_type          = var.default_instance_type
  default_instance_count         = var.default_instance_count
  ip_access_whitelist            = var.ip_access_whitelist
  min_node_fleet_requests_count  = var.min_node_fleet_requests_count
  max_node_fleet_requests_count  = var.max_node_fleet_requests_count
  default_node_fleet_bid         = var.default_node_fleet_bid
  node_fleet_allocation_strategy = var.node_fleet_allocation_strategy
  node_fleet_valid_until         = var.node_fleet_valid_until
  node_instance_type             = var.node_instance_type
}

module "build_agent" {
  source                      = "./modules/drone-agent"
  rpc_server                  = local.rpc_server_url
  rpc_secret                  = local.rpc_secret
  cluster_id                  = local.cluster_id
  cluster_name                = local.cluster_name
  fqdn                        = local.fqdn
  drone_secrets_shared_secret = local.drone_secrets_shared_secret
  drone_secrets_url           = local.drone_secrets_url
  aws_region                  = var.aws_region
  app_version                 = var.drone_version
  app_debug                   = var.env_drone_logs_debug
  container_cpu               = var.ecs_container_cpu
  container_memory            = var.ecs_container_memory
  min_container_count         = var.drone_agent_min_count
  max_container_count         = var.drone_agent_max_count
}

module "ci_server" {
  source                             = "./modules/drone-server"
  db_host_name                       = local.db_host_name
  db_user                            = local.db_user
  db_password                        = local.db_password
  db_engine                          = local.db_engine
  db_port                            = local.db_port
  rpc_secret                         = local.rpc_secret
  agent_log_group_arn                = local.agent_log_group_arn
  cluster_name                       = local.cluster_name
  cluster_id                         = local.cluster_id
  public_subnets                     = local.public_subnets
  private_subnets                    = local.private_subnets
  vpc_id                             = local.vpc_id
  cluster_instance_security_group_id = local.cluster_instance_security_group_id
  env_drone_admin                    = var.env_drone_admin
  env_drone_github_organization      = var.env_drone_github_organization
  env_drone_webhook_list             = var.env_drone_webhook_list
  env_drone_logs_debug               = var.env_drone_logs_debug
  env_drone_repo_filter              = var.env_drone_repo_filter
  fargate_task_cpu                   = var.fargate_task_cpu
  fargate_task_memory                = var.fargate_task_memory
  fqdn                               = local.fqdn
  sub_domain                         = var.ci_sub_domain
  aws_region                         = var.aws_region
  app_version                        = var.drone_version
  app_debug                          = var.env_drone_logs_debug
  app_port                           = var.drone_server_port
  build_agent_port                   = var.drone_agent_port
  ip_access_whitelist                = var.ip_access_whitelist
  root_domain_zone_id                = var.root_domain_zone_id
}
