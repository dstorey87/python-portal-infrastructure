# =============================================================================
# DEVELOPMENT ENVIRONMENT CONFIGURATION
# Python Learning Portal - Local Development
# =============================================================================

# Project Configuration
project_name = "python-portal"
environment  = "development"

# Lightsail Container Service Configuration
service_name = "python-portal-dev"
power        = "nano"  # Minimal resources for development
scale        = 1

# Container Services Configuration
services = {
  backend = {
    image  = "python-portal-backend:dev"
    port   = 3000
    cpu    = 256
    memory = 256
    scale  = 1
    environment = {
      NODE_ENV = "development"
      PORT     = "3000"
      CORS_ORIGIN = "*"
      DEBUG    = "true"
    }
  }
  
  frontend = {
    image  = "python-portal-frontend:dev"
    port   = 80
    cpu    = 128
    memory = 128
    scale  = 1
    environment = {
      NODE_ENV = "development"
      API_URL  = "http://localhost:3000/api"
    }
  }
  
  executor = {
    image  = "python-portal-executor:dev"
    port   = 8000
    cpu    = 128
    memory = 128
    scale  = 1
    environment = {
      PYTHON_ENV = "development"
      DEBUG      = "true"
      TIMEOUT    = "60"
    }
  }
}

# Public Endpoint Configuration
public_endpoint = {
  container_name = "frontend"
  container_port = 80
  health_check = {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout_seconds     = 10
    interval_seconds    = 60
    path               = "/health"
    success_codes      = "200,404"
  }
}

# Development Budget (Lower limit)
budget_amount    = 20  # Development environment limit
notification_email = "darren.storey87@gmail.com"

alert_thresholds = [
  { threshold = 50, type = "FORECASTED" },
  { threshold = 80, type = "ACTUAL" }
]

# Security Configuration
secrets = {
  # Development secrets (non-sensitive)
}

# Feature Flags
enable_cost_anomaly_detection = false  # Disabled for dev
enable_dashboard              = false  # Disabled for dev

# Resource Tagging
tags = {
  Project     = "python-portal"
  Environment = "development"
  Owner       = "dstorey87"
  Terraform   = "true"
  Repository  = "python-portal-infrastructure"
}