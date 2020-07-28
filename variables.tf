variable "db_identifier" {
  default     = "ci-rds"
  description = "Identifier for RDS instance"
}

variable "db_storage_size" {
  default     = 10
  description = "Storage size of RDS instance in GB"
}

variable "db_instance_type" {
  default     = "db.t3.micro"
  description = "RDS instance types "
}

variable "db_name" {
  default     = "ci_db"
  description = "Database Name"
}

variable "db_user" {
  default     = "ci_user"
  description = "Database user name"
}

variable "aws_region" {
  description = "AWS region where the CI/CD gets deployed"
  default     = "eu-west-1"
}

variable "root_domain_zone_id" {
  description = "Pre-existing Route53 Hosted Zone ID"
}

variable "root_domain" {
  default     = "example.com"
  description = "Pre-existing Route53 Hosted Zone domain"
}

variable "ci_sub_domain" {
  default     = "ci"
  description = "Sub-domain / hostname to access ci"
}

variable "ip_access_whitelist" {
  description = "White-listed cidr IP to access user interface. Allow from [Github Hook IP](https://api.github.com/meta)   "
  default     = ["0.0.0.0/0"]
}

variable "keypair_public_key" {
  description = "Pubkey of A pre-existing keypair"
}

variable "default_ttl" {
  default     = 300
  description = "Default ttl for domain records"
}

variable "default_instance_count" {
  description = "Number of instances not from spotfleet"
  default     = 0
}


variable "default_instance_type" {
  description = "Instance type of instances not from spotfleet"
  default     = "t3.medium"
}

variable "ecs_container_cpu" {
  description = "Requested ecs container CPU"
  default     = 2000
}

variable "ecs_container_memory" {
  description = "Requested ecs container memory"
  default     = 768
}

variable "fargate_task_cpu" {
  default     = 256
  description = " [Fargate task CPU and memory at the task level](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
}

variable "fargate_task_memory" {
  description = " [Fargate task CPU and memory at the task level](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
  default     = 512
}

variable "drone_server_port" {
  description = "Port of Drone Server"
  default     = 80
}

variable "drone_agent_port" {
  description = "Port of drone agent."
  default     = 80
}

variable "drone_agent_min_count" {
  description = "Min drone agens running."
  default     = 4
}

variable "drone_agent_max_count" {
  description = "Max drone agents running."
  default     = 50
}

variable "drone_version" {
  description = "Ci Drone version."
  default     = "1.2.1"
}

variable "env_drone_admin" {
  description = "Drone privileged User"
}

variable "env_drone_github_organization" {
  description = "Registration is limited to users included in this list, or users that are members of organizations included in this list."
}

variable "env_drone_webhook_list" {
  description = "String literal value provides a comma-separated list of webhook endpoints"
  default     = "https://localhost?lis45"
}

variable "env_drone_logs_debug" {
  description = "String literal for verboser output from logs "
  default     = false
}

variable "env_drone_repo_filter" {
  description = "whitliest repositories"
}

variable "ec2_volume_size" {
  default     = 30
  description = "Size of ec2 disk in GB"
}

variable "min_node_fleet_requests_count" {
  description = "Min slaves"
  default     = 2
}

variable "max_node_fleet_requests_count" {
  description = "Max slaves"
  default     = 4
}

variable "node_fleet_allocation_strategy" {
  default     = "diversified"
  description = "Strategy for seeding instances cross pools. Config only support one pool for now."
}

variable "node_fleet_valid_until" {
  description = "Amount of time a spot fleet bid should stay active"
  default     = "2022-02-22T02:02:02Z"
}

variable "node_instance_type" {
  type        = map
  description = "Node instance type"
  default = {
    t3Medium = {
      price = 0.02
      name  = "t3.medium"
    }
    m5Large = {
      price = 0.04
      name  = "m5.large"
    }
  }
}

variable "default_node_fleet_bid" {
  default     = 0.007
  description = "Bid price for cluster resources"
}

variable "update_dns_lambda_name" {
  description = "Function name for lambda used to update DNS of drone server"
  default     = "update_drone_ci_domain"
}

variable "vpc_public_subnets" {
  type    = list
  default = ["172.35.16.0/22", "172.35.20.0/22", "172.35.24.0/22"]
}

variable "vpc_private_subnets" {
  type    = list
  default = ["172.35.116.0/22", "172.35.120.0/22", "172.35.124.0/22"]
}

variable "vpc_cidr" {
  type    = string
  default = "172.35.0.0/16"
}