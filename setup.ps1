# Navigate to the terraform directory
cd terraform

# Initialize Terraform (in case it's a fresh run)
terraform init

# Apply configuration
terraform apply -auto-approve

# Navigate back
cd ..

Write-Host "Infrastructure setup successfully."
