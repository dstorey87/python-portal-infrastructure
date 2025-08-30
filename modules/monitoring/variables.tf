# =============================================================================
# MONITORING MODULE VARIABLES
# =============================================================================

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
}

variable "budget_amount" {
  description = "Budget amount in USD"
  type        = number
  
  validation {
    condition     = var.budget_amount > 0 && var.budget_amount <= 100
    error_message = "Budget amount must be between 1 and 100 USD."
  }
}

variable "alert_thresholds" {
  description = "List of alert thresholds"
  type = list(object({
    threshold = number
    type     = string
  }))
  
  default = [
    { threshold = 50, type = "FORECASTED" },
    { threshold = 80, type = "ACTUAL" }
  ]
}

variable "notification_email" {
  description = "Email address for budget notifications"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.notification_email))
    error_message = "Must be a valid email address."
  }
}

variable "enable_cost_anomaly_detection" {
  description = "Enable cost anomaly detection"
  type        = bool
  default     = true
}

variable "enable_dashboard" {
  description = "Enable CloudWatch dashboard"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}