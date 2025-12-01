# Disaster Recovery & Account Migration Plan

## Overview
This guide explains how to completely migrate your CareConnect infrastructure (App + DevOps) to a **new AWS Account** in case of account suspension or other disasters.

## Prerequisites
1.  **New AWS Account**: Created and active.
2.  **AWS CLI**: Installed on your local machine.
3.  **Terraform**: Installed on your local machine.
4.  **Source Code**: This folder (`v6`) backed up locally or on GitHub.

## Migration Steps

### 1. Clean Local State
Remove the old Terraform state files that are tied to the old account.
```powershell
cd terraform
Remove-Item -Recurse .terraform
Remove-Item *.tfstate
Remove-Item *.tfstate.backup
```

### 2. Configure New Credentials
Configure the AWS CLI with the **Access Keys** of the *new* account.
```powershell
aws configure
# Enter new Access Key ID
# Enter new Secret Access Key
# Region: ap-south-1
```

### 3. Update GitHub Secrets
If you are using GitHub Actions:
1.  Go to your GitHub Repository > Settings > Secrets.
2.  Update `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` with the new account's credentials.

### 4. Re-Provision Infrastructure
Run the setup script to deploy everything to the new account.
```powershell
cd ..
.\setup_daily.ps1
```

### 5. Verify
1.  **App**: Check the new ALB URL output by the script.
2.  **DevOps**: Check the new Jenkins/SonarQube URL.
3.  **Data**: Note that *data* in the old EC2 instances (like `appointments.json`) will be lost unless you backed it up externally (e.g., to S3 or Git). Since your app pushes `appointments.json` to Git (not recommended for production but fine here), your data is safe in GitHub!

## Summary
By following these steps, you can restore your entire environment in a new AWS account in **under 10 minutes**.
