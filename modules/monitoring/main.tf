# =============================================================================
# COST MONITORING MODULE
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
# BUDGET FOR COST CONTROL
# =============================================================================

resource "aws_budgets_budget" "project_budget" {
  name         = "${var.project_name}-${var.environment}-budget"
  budget_type  = "COST"
  limit_amount = tostring(var.budget_amount)
  limit_unit   = "USD"
  time_unit    = "ANNUALLY"
  time_period_start = "2025-01-01_00:00"
  
  cost_filters = {
    TagKey = ["Project"]
    TagValues = [var.project_name]
  }
  
  # Progressive notifications
  dynamic "notification" {
    for_each = var.alert_thresholds
    
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                 = notification.value.threshold
      threshold_type            = "PERCENTAGE"
      notification_type         = notification.value.type
      subscriber_email_addresses = [var.notification_email]
    }
  }
  
  # Automatic actions when approaching limit
  dynamic "cost_anomaly_detection" {
    for_each = var.enable_cost_anomaly_detection ? [1] : []
    
    content {
      monitor_arn_list = [aws_ce_anomaly_monitor.cost_monitor[0].arn]
    }
  }
  
  tags = var.tags
}

# =============================================================================
# COST ANOMALY DETECTION
# =============================================================================

resource "aws_ce_anomaly_monitor" "cost_monitor" {
  count = var.enable_cost_anomaly_detection ? 1 : 0
  
  name         = "${var.project_name}-${var.environment}-anomaly-monitor"
  monitor_type = "DIMENSIONAL"
  
  specification = jsonencode({
    Dimension = "SERVICE"
    MatchOptions = ["EQUALS"]
    Values = ["Amazon Lightsail"]
  })
  
  tags = var.tags
}

resource "aws_ce_anomaly_detector" "cost_detector" {
  count = var.enable_cost_anomaly_detection ? 1 : 0
  
  name           = "${var.project_name}-${var.environment}-anomaly-detector"
  detector_type  = "DIMENSIONAL"
  frequency      = "DAILY"
  
  monitor_arn_list = [aws_ce_anomaly_monitor.cost_monitor[0].arn]
  
  tags = var.tags
}

# =============================================================================
# CLOUDWATCH DASHBOARD FOR COST MONITORING
# =============================================================================

resource "aws_cloudwatch_dashboard" "cost_dashboard" {
  count = var.enable_dashboard ? 1 : 0
  
  dashboard_name = "${var.project_name}-${var.environment}-costs"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        
        properties = {
          metrics = [
            ["AWS/Billing", "EstimatedCharges", "Currency", "USD"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Estimated Monthly Charges"
          period  = 86400
          stat    = "Maximum"
        }
      }
    ]
  })
  
  tags = var.tags
}

# =============================================================================
# OUTPUTS
# =============================================================================

output "budget_name" {
  description = "Name of the created budget"
  value       = aws_budgets_budget.project_budget.name
}

output "budget_arn" {
  description = "ARN of the created budget"
  value       = aws_budgets_budget.project_budget.arn
}

output "anomaly_detector_arn" {
  description = "ARN of the cost anomaly detector"
  value       = var.enable_cost_anomaly_detection ? aws_ce_anomaly_detector.cost_detector[0].arn : null
}

output "dashboard_url" {
  description = "URL of the cost monitoring dashboard"
  value       = var.enable_dashboard ? "https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=${aws_cloudwatch_dashboard.cost_dashboard[0].dashboard_name}" : null
}