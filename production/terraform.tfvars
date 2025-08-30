# =============================================================================
# PRODUCTION ENVIRONMENT VARIABLES
# Python Learning Portal - AWS Lightsail Deployment
# =============================================================================

# Project Configuration
project_name = "python-portal"
environment  = "production"

# Lightsail Container Service Configuration
service_name = "python-portal-prod"
power        = "nano"  # Free tier: 0.25 vCPU, 512 MB RAM
scale        = 1       # Single instance for cost optimization

# Container Services Configuration
services = {
  backend = {
    image  = "python-portal-backend:latest"
    port   = 3000
    cpu    = 256   # 0.25 vCPU allocation
    memory = 256   # 256 MB RAM allocation
    scale  = 1
    environment = {
      NODE_ENV = "production"
      PORT     = "3000"
      CORS_ORIGIN = "https://*.nf0keysv54fy8.eu-west-1.cs.amazonlightsail.com"
    }
  }
  
  frontend = {
    image  = "python-portal-frontend:latest"
    port   = 80
    cpu    = 128   # 0.125 vCPU allocation
    memory = 128   # 128 MB RAM allocation
    scale  = 1
    environment = {
      NGINX_ENV = "production"
      API_URL   = "https://python-portal-prod.nf0keysv54fy8.eu-west-1.cs.amazonlightsail.com/api"
    }
  }
  
  executor = {
    image  = "python-portal-executor:latest"
    port   = 8000
    cpu    = 128   # 0.125 vCPU allocation for Python execution
    memory = 128   # 128 MB RAM allocation
    scale  = 1
    environment = {
      PYTHON_ENV = "production"
      TIMEOUT    = "30"
    }
  }
}

# Public Endpoint Configuration
public_endpoint = {
  container_name = "frontend"
  container_port = 80
  health_check = {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout_seconds     = 5
    interval_seconds    = 30
    path               = "/health"
    success_codes      = "200"
  }
}

# Cost Control Configuration (STRICT $85/year limit)
budget_amount    = 85  # Annual budget limit
notification_email = "darren.storey87@gmail.com"

alert_thresholds = [
  { threshold = 25, type = "FORECASTED" },  # Early warning
  { threshold = 50, type = "FORECASTED" },  # Mid-point alert
  { threshold = 75, type = "ACTUAL" },      # Critical warning
  { threshold = 90, type = "ACTUAL" }       # Emergency alert
]

# Security Configuration
secrets = {
  # Add secrets as needed - these will be stored in Parameter Store
  # Example:
  # "database_password" = "secure_password_here"
  # "api_key" = "secret_api_key_here"
}

# Feature Flags
enable_cost_anomaly_detection = true
enable_dashboard              = true

# Resource Tagging
tags = {
  Project     = "python-portal"
  Environment = "production"
  Owner       = "dstorey87"
  CostCenter  = "learning-platform"
  Terraform   = "true"
  Repository  = "python-portal-infrastructure"
}