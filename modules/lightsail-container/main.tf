# =============================================================================
# LIGHTSAIL CONTAINER SERVICE MODULE
# =============================================================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# =============================================================================
# CONTAINER SERVICE
# =============================================================================

resource "aws_lightsail_container_service" "main" {
  name  = var.service_name
  power = var.power
  scale = var.scale
  
  # Public endpoint configuration
  public_domain_names = var.public_domain_names
  
  tags = var.tags
}

# =============================================================================
# CONTAINER SERVICE DEPLOYMENT
# =============================================================================

resource "aws_lightsail_container_service_deployment_version" "main" {
  service_name = aws_lightsail_container_service.main.name
  
  # Configure containers for each service
  dynamic "container" {
    for_each = var.services
    
    content {
      container_name = container.key
      image         = container.value.image
      
      # Resource allocation
      command = []
      
      # Environment variables
      environment = container.value.environment
      
      # Port configuration
      ports = {
        (tostring(container.value.port)) = "HTTP"
      }
    }
  }
  
  # Public endpoint configuration
  public_endpoint {
    container_name = var.public_endpoint.container_name
    container_port = var.public_endpoint.container_port
    
    health_check {
      healthy_threshold   = var.public_endpoint.health_check.healthy_threshold
      unhealthy_threshold = var.public_endpoint.health_check.unhealthy_threshold
      timeout_seconds     = var.public_endpoint.health_check.timeout_seconds
      interval_seconds    = var.public_endpoint.health_check.interval_seconds
      path               = var.public_endpoint.health_check.path
      success_codes      = var.public_endpoint.health_check.success_codes
    }
  }
}

# =============================================================================
# OUTPUTS
# =============================================================================

output "service_name" {
  description = "Name of the container service"
  value       = aws_lightsail_container_service.main.name
}

output "service_arn" {
  description = "ARN of the container service"
  value       = aws_lightsail_container_service.main.arn
}

output "public_domain_name" {
  description = "Public domain name of the service"
  value       = "https://${aws_lightsail_container_service.main.public_domain_names[0]}"
}

output "state" {
  description = "Current state of the container service"
  value       = aws_lightsail_container_service.main.state
}

output "url" {
  description = "URL of the deployed application"
  value       = aws_lightsail_container_service.main.url
}

output "created_at" {
  description = "Creation timestamp"
  value       = aws_lightsail_container_service.main.created_at
}