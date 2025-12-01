# Navigate to the terraform directory
cd terraform

# Destroy all resources
terraform destroy -auto-approve

# Navigate back
cd ..

Write-Host "Infrastructure destroyed successfully."
