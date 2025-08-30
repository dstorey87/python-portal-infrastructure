# =============================================================================
# PRODUCTION ENVIRONMENT - PYTHON LEARNING PORTAL
# =============================================================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Terraform Cloud backend for state management (FREE tier)
  cloud {
    organization = "python-portal"
    workspaces {
      name = "python-portal-production"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = local.common_tags
  }
}

# =============================================================================
# LOCAL VALUES & CONFIGURATION
# =============================================================================

locals {
  environment = "production"
  project     = "python-portal"
  
  common_tags = {
    Environment   = local.environment
    Project       = local.project
    Owner         = var.owner
    CostCenter    = "free-tier"
    Terraform     = "true"
    DeployedBy    = "github-actions"
    LastModified  = timestamp()
  }
  
  # Container service configuration
  services = {
    frontend = {
      image = "ghcr.io/dstorey87/python-portal-frontend:latest"
      port  = 80
      cpu   = 0.25
      memory = 0.5
      scale  = 1
      environment = {
        NODE_ENV = "production"
        API_URL  = "https://${var.domain_name}"
      }
    }
    
    backend = {
      image = "ghcr.io/dstorey87/python-portal-backend:latest"
      port  = 3000
      cpu   = 0.25
      memory = 0.5
      scale  = 2
      environment = {
        NODE_ENV = "production"
        PORT     = "3000"
        EXECUTOR_URL = "http://localhost:3001"
      }
    }
    
    executor = {
      image = "ghcr.io/dstorey87/python-portal-executor:latest"
      port  = 3001
      cpu   = 0.25
      memory = 0.5
      scale  = 2
      environment = {
        NODE_ENV = "production"
        PORT     = "3001"
        PYTHON_TIMEOUT = "5000"
      }
    }
  }
}

# =============================================================================
# LIGHTSAIL CONTAINER SERVICE
# =============================================================================

module "lightsail_containers" {
  source = "../../modules/lightsail-container"
  
  service_name = "${local.project}-${local.environment}"
  power        = "nano"  # 0.25 vCPU, 0.5 GB RAM (cheapest option)
  scale        = 1       # Single container node
  
  services = local.services
  
  # Public endpoint configuration
  public_endpoint = {
    container_name = "frontend"
    container_port = 80
    health_check = {
      healthy_threshold   = 2
      unhealthy_threshold = 10
      timeout_seconds     = 30
      interval_seconds    = 300
      path               = "/health"
      success_codes      = "200-299"
    }
  }
  
  tags = local.common_tags
}

# =============================================================================
# COST MONITORING & BUDGETS
# =============================================================================

module "cost_monitoring" {
  source = "../../modules/monitoring"
  
  project_name = local.project
  environment  = local.environment
  
  # Budget configuration - STRICT $85 annual limit
  budget_amount = var.annual_budget_limit
  
  # Alert thresholds (progressive alerting)
  alert_thresholds = [
    { threshold = 25, type = "FORECASTED" },  # $21.25
    { threshold = 50, type = "ACTUAL" },      # $42.50
    { threshold = 75, type = "ACTUAL" },      # $63.75
    { threshold = 90, type = "ACTUAL" }       # $76.50
  ]
  
  notification_email = var.notification_email
  
  tags = local.common_tags
}

# =============================================================================
# SECURITY & SECRETS MANAGEMENT
# =============================================================================

module "security" {
  source = "../../modules/security"
  
  project_name = local.project
  environment  = local.environment
  
  # Parameter Store secrets
  secrets = {
    database_url    = var.database_url
    jwt_secret      = var.jwt_secret
    session_secret  = var.session_secret
  }
  
  tags = local.common_tags
}

# =============================================================================
# OUTPUTS
# =============================================================================

output "container_service_url" {
  description = "URL of the deployed container service"
  value       = module.lightsail_containers.public_domain_name
}

output "container_service_state" {
  description = "State of the container service"
  value       = module.lightsail_containers.state
}

output "budget_name" {
  description = "Name of the cost monitoring budget"
  value       = module.cost_monitoring.budget_name
}

output "estimated_monthly_cost" {
  description = "Estimated monthly cost in USD"
  value       = "$10.00" # Lightsail Container Service after free tier
}

output "deployment_info" {
  description = "Deployment information"
  value = {
    environment     = local.environment
    services_count  = length(local.services)
    total_containers = sum([for service in local.services : service.scale])
    deployment_time = timestamp()
  }
}