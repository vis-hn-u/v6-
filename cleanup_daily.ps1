# Daily Cleanup Script
Write-Host "Starting Daily Infrastructure Teardown..." -ForegroundColor Red

cd terraform

# Destroy Infrastructure
terraform destroy -auto-approve

Write-Host "`n--------------------------------------------------" -ForegroundColor Green
Write-Host "All Resources Destroyed. Free Tier hours saved!" -ForegroundColor Green
Write-Host "--------------------------------------------------" -ForegroundColor Green

cd ..
