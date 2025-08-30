# Python Portal Infrastructure

## Production-Grade Infrastructure as Code

This repository contains the complete Infrastructure as Code (IaC) setup for the Python Learning Portal using Terraform and AWS Lightsail Container Service.

## 🏗️ Architecture

```
python-portal-infrastructure/
├── production/
│   ├── main.tf              # Production environment
│   ├── terraform.tfvars     # Production variables
│   └── backend.hcl          # Remote state config
├── development/
│   ├── main.tf              # Development environment  
│   ├── terraform.tfvars     # Development variables
│   └── backend.hcl          # Remote state config
├── modules/
│   ├── lightsail-container/ # Lightsail container service
│   ├── monitoring/          # Cost monitoring & alerts
│   └── security/            # IAM roles & Parameter Store
└── scripts/
    └── deploy.sh           # Deployment automation
```

## 💰 Cost Optimization

**Strict Budget Control**: $85/year maximum
- **Free Tier**: 3 months free Lightsail Container Service
- **Production Cost**: $10/month after free tier
- **Annual Cost**: ~$75/year (well within budget)
- **Progressive Alerts**: 25%, 50%, 75%, 90% thresholds
- **Anomaly Detection**: Automatic cost spike detection

## 🚀 Quick Start

### Prerequisites
```bash
# Install Terraform
choco install terraform  # Windows
# or
brew install terraform    # macOS

# Configure AWS CLI
aws configure
```

### Deploy Production Environment
```bash
# Clone repository
git clone https://github.com/dstorey87/python-portal-infrastructure.git
cd python-portal-infrastructure

# Initialize Terraform
terraform init -chdir=production

# Plan deployment
terraform plan -chdir=production -var-file="terraform.tfvars"

# Apply changes
terraform apply -chdir=production -var-file="terraform.tfvars"
```

### Deploy Development Environment
```bash
# Initialize development environment
terraform init -chdir=development

# Deploy development stack
terraform apply -chdir=development -var-file="terraform.tfvars"
```

## 📊 Monitoring & Alerts

- **AWS Budgets**: Automatic cost monitoring
- **CloudWatch**: Cost anomaly detection  
- **Email Alerts**: Progressive threshold notifications
- **Dashboard**: Real-time cost visualization

## 🔒 Security Features

- **IAM Roles**: Least privilege access
- **Parameter Store**: Encrypted secret management
- **CloudWatch Logs**: Centralized logging
- **Health Checks**: Container health monitoring

## 🏭 Production Features

- **Multi-Container**: Frontend, Backend, Python Executor
- **Health Checks**: Automatic failure detection
- **Auto Scaling**: Horizontal scaling support
- **Custom Domains**: HTTPS certificate management
- **Zero Downtime**: Rolling deployments

## 📋 Environment Variables

### Production
```hcl
project_name = "python-portal"
environment  = "production"
service_name = "python-portal-prod"
power        = "nano"  # 0.25 vCPU, 512 MB RAM
budget_amount = 85     # Annual limit
```

### Development
```hcl
project_name = "python-portal"
environment  = "development"
service_name = "python-portal-dev"
power        = "nano"
budget_amount = 20     # Development limit
```

## 🔧 Module Usage

### Lightsail Container Service
```hcl
module "container_service" {
  source = "./modules/lightsail-container"
  
  service_name = var.service_name
  power        = var.power
  scale        = var.scale
  services     = var.services
  
  public_endpoint = var.public_endpoint
  tags           = var.tags
}
```

### Cost Monitoring
```hcl
module "monitoring" {
  source = "./modules/monitoring"
  
  project_name   = var.project_name
  environment    = var.environment
  budget_amount  = var.budget_amount
  
  notification_email = var.notification_email
  alert_thresholds  = var.alert_thresholds
  
  tags = var.tags
}
```

### Security
```hcl
module "security" {
  source = "./modules/security"
  
  project_name = var.project_name
  environment  = var.environment
  secrets     = var.secrets
  
  tags = var.tags
}
```

## 📈 Scaling Strategy

1. **Vertical Scaling**: nano → micro → small
2. **Horizontal Scaling**: Increase scale parameter
3. **Cost Impact**: Each tier doubles cost and resources
4. **Budget Monitoring**: Automatic alerts before exceeding limits

## 🧪 Testing

```bash
# Validate Terraform configuration
terraform validate

# Security scanning
tfsec .

# Cost estimation
terraform plan | grep -E "Plan:|Changes:"

# Lint configuration
tflint
```

## 📚 Documentation

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Lightsail Container Service](https://docs.aws.amazon.com/lightsail/latest/userguide/amazon-lightsail-container-services.html)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [Terraform Modules](https://developer.hashicorp.com/terraform/language/modules)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Test changes thoroughly
4. Ensure cost compliance
5. Submit pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) file

---

**Cost Alert**: Always verify deployment costs before applying changes. Stay within the $85/year budget limit.