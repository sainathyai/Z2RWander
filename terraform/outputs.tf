# Outputs are defined in main.tf to avoid duplication
# This file is kept for reference but outputs are in main.tf

output "cluster_ca_certificate" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_ca_certificate
  sensitive   = true
}

output "ecr_static_app_repository_url" {
  description = "ECR repository URL for static app"
  value       = aws_ecr_repository.static_app.repository_url
}

output "ecr_login_command" {
  description = "Command to login to ECR"
  value       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}

