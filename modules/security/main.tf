# =============================================================================
# SECURITY MODULE - PARAMETER STORE & IAM
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
# PARAMETER STORE FOR SECRETS
# =============================================================================

resource "aws_ssm_parameter" "secrets" {
  for_each = var.secrets
  
  name  = "/${var.project_name}/${var.environment}/${each.key}"
  type  = "SecureString"
  value = each.value
  
  description = "Secret for ${each.key} in ${var.environment} environment"
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-${each.key}"
    Type = "Secret"
  })
}

# =============================================================================
# IAM ROLE FOR CONTAINER SERVICE
# =============================================================================

resource "aws_iam_role" "container_service_role" {
  name = "${var.project_name}-${var.environment}-container-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lightsail.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.tags
}

# =============================================================================
# IAM POLICY FOR PARAMETER STORE ACCESS
# =============================================================================

resource "aws_iam_policy" "parameter_store_access" {
  name        = "${var.project_name}-${var.environment}-parameter-store-access"
  description = "Allow access to Parameter Store secrets"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/${var.project_name}/${var.environment}/*"
      }
    ]
  })
  
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "parameter_store_access" {
  role       = aws_iam_role.container_service_role.name
  policy_arn = aws_iam_policy.parameter_store_access.arn
}

# =============================================================================
# IAM POLICY FOR CLOUDWATCH LOGS
# =============================================================================

resource "aws_iam_policy" "cloudwatch_logs" {
  name        = "${var.project_name}-${var.environment}-cloudwatch-logs"
  description = "Allow writing to CloudWatch Logs"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:log-group:/aws/lightsail/${var.project_name}-${var.environment}*"
      }
    ]
  })
  
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.container_service_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs.arn
}

# =============================================================================
# OUTPUTS
# =============================================================================

output "parameter_store_paths" {
  description = "Paths of created Parameter Store parameters"
  value       = [for param in aws_ssm_parameter.secrets : param.name]
}

output "container_service_role_arn" {
  description = "ARN of the container service IAM role"
  value       = aws_iam_role.container_service_role.arn
}

output "parameter_store_policy_arn" {
  description = "ARN of the Parameter Store access policy"
  value       = aws_iam_policy.parameter_store_access.arn
}

output "cloudwatch_logs_policy_arn" {
  description = "ARN of the CloudWatch Logs policy"
  value       = aws_iam_policy.cloudwatch_logs.arn
}