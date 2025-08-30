# =============================================================================
# LIGHTSAIL CONTAINER MODULE VARIABLES
# =============================================================================

variable "service_name" {
  description = "Name of the Lightsail container service"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{0,62}$", var.service_name))
    error_message = "Service name must be 1-63 characters, start with a letter, and contain only letters, numbers, and hyphens."
  }
}

variable "power" {
  description = "Power specification for the container service"
  type        = string
  default     = "nano"
  
  validation {
    condition = contains([
      "nano", "micro", "small", "medium", "large", "xlarge"
    ], var.power)
    error_message = "Power must be one of: nano, micro, small, medium, large, xlarge."
  }
}

variable "scale" {
  description = "Number of container nodes"
  type        = number
  default     = 1
  
  validation {
    condition     = var.scale >= 1 && var.scale <= 20
    error_message = "Scale must be between 1 and 20."
  }
}

variable "services" {
  description = "Map of services to deploy"
  type = map(object({
    image = string
    port  = number
    cpu   = number
    memory = number
    scale  = number
    environment = map(string)
  }))
}

variable "public_endpoint" {
  description = "Public endpoint configuration"
  type = object({
    container_name = string
    container_port = number
    health_check = object({
      healthy_threshold   = number
      unhealthy_threshold = number
      timeout_seconds     = number
      interval_seconds    = number
      path               = string
      success_codes      = string
    })
  })
}

variable "public_domain_names" {
  description = "Custom domain names for the service"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}