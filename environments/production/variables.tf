# =============================================================================
# PRODUCTION ENVIRONMENT VARIABLES
# =============================================================================

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition = contains([
      "us-east-1", "us-west-2", "eu-west-1", "ap-southeast-1"
    ], var.aws_region)
    error_message = "Region must be a supported Lightsail region."
  }
}

variable "domain_name" {
  description = "Custom domain name for the application"
  type        = string
  default     = "python-portal-real.nf0keysv54fy8.eu-west-1.cs.amazonlightsail.com"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "dstorey87"
}

variable "notification_email" {
  description = "Email for cost and monitoring alerts"
  type        = string
  sensitive   = true
}

variable "annual_budget_limit" {
  description = "Annual budget limit in USD"
  type        = number
  default     = 85
  
  validation {
    condition     = var.annual_budget_limit <= 85
    error_message = "Budget limit must not exceed $85 to stay within free tier allowance."
  }
}

# =============================================================================
# SECRET VARIABLES (Managed via Parameter Store)
# =============================================================================

variable "database_url" {
  description = "Database connection URL"
  type        = string
  sensitive   = true
  default     = "file:./data/database.db"
}

variable "jwt_secret" {
  description = "JWT signing secret"
  type        = string
  sensitive   = true
}

variable "session_secret" {
  description = "Session encryption secret"
  type        = string
  sensitive   = true
}

# =============================================================================
# CONTAINER CONFIGURATION
# =============================================================================

variable "container_images" {
  description = "Container images for each service"
  type = object({
    frontend = string
    backend  = string
    executor = string
  })
  
  default = {
    frontend = "ghcr.io/dstorey87/python-portal-frontend:latest"
    backend  = "ghcr.io/dstorey87/python-portal-backend:latest"
    executor = "ghcr.io/dstorey87/python-portal-executor:latest"
  }
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring and logging"
  type        = bool
  default     = true
}

variable "enable_auto_scaling" {
  description = "Enable automatic scaling based on metrics"
  type        = bool
  default     = false  # Disabled to control costs
}

variable "deployment_timeout" {
  description = "Deployment timeout in minutes"
  type        = number
  default     = 30
  
  validation {
    condition     = var.deployment_timeout >= 10 && var.deployment_timeout <= 60
    error_message = "Deployment timeout must be between 10 and 60 minutes."
  }
}