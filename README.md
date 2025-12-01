# CareConnect

CareConnect is a static website for booking doctor appointments, served by a Node.js Express server. It is containerized with Docker and designed to be deployed on AWS EC2 using Terraform.

## 🚀 Quick Start

### Prerequisites
- Docker installed
- Node.js (optional, for local dev without Docker)

### Run with Docker
1. **Build the image**:
   ```bash
   docker build -t careconnect .
   ```
2. **Run the container**:
   ```bash
   docker run -p 3000:3000 careconnect
   ```
3. Open [http://localhost:3000](http://localhost:3000).

### Run Locally (Node.js)
1. Install dependencies: `npm install`
2. Start server: `npm start`

## ☁️ Deployment (AWS EC2)

This project uses Terraform to provision an EC2 instance that automatically installs Docker and runs the application.

### Prerequisites
- AWS CLI configured
- Terraform installed

### Deploy
1. Navigate to `terraform/`:
   ```bash
   cd terraform
   ```
2. Initialize and Apply:
   ```bash
   terraform init
   terraform apply
   ```
3. Confirm with `yes`.
4. Access the site using the `public_ip` outputted by Terraform.

## 🛠️ Architecture
- **Frontend**: HTML/CSS/JS (Static)
- **Backend**: Node.js Express (Serves static files)
- **Infrastructure**: AWS EC2 (Provisioned via Terraform)
- **CI/CD**: GitHub Actions (Builds Docker image on push)

## ⚙️ CI/CD Setup (GitHub Actions)

To enable the automated deployment pipeline, you need to configure secrets in your GitHub repository.

1.  Go to your repository on GitHub.
2.  Click on **Settings** > **Secrets and variables** > **Actions**.
3.  Click **New repository secret**.
4.  Add the following secrets:
    -   `AWS_ACCESS_KEY_ID`: Your AWS Access Key ID.
    -   `AWS_SECRET_ACCESS_KEY`: Your AWS Secret Access Key.
    -   `AWS_REGION`: `ap-south-1` (or your preferred region).