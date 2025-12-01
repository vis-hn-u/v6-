# Daily Setup Script
Write-Host "Starting Daily Infrastructure Setup..." -ForegroundColor Green

# 1. Initialize Terraform
cd terraform
terraform init

# 2. Apply Infrastructure
Write-Host "Provisioning AWS Resources..." -ForegroundColor Cyan
terraform apply -auto-approve

# 3. Output Connection Details
$devops_ip = terraform output -raw devops_server_ip
$alb_url = terraform output -raw alb_dns_name

Write-Host "`n--------------------------------------------------" -ForegroundColor Green
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "DevOps Server (Jenkins/SonarQube): http://$devops_ip:8080" -ForegroundColor Yellow
Write-Host "Application URL: http://$alb_url" -ForegroundColor Yellow
Write-Host "--------------------------------------------------" -ForegroundColor Green

cd ..
