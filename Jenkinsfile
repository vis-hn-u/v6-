pipeline {
    agent any

    environment {
        ECR_REPO = '354918363748.dkr.ecr.ap-south-1.amazonaws.com/careconnect-repo'
        AWS_REGION = 'ap-south-1'
        SONAR_HOST = 'http://13.201.123.250:9000'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarScanner'
                    withSonarQubeEnv('SonarQube') {
                        sh "${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=CareConnect \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=${SONAR_HOST} \
                        -Dsonar.login=${SONAR_AUTH_TOKEN}"
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${ECR_REPO}:latest ."
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}"
                    sh "docker push ${ECR_REPO}:latest"
                }
            }
        }

        stage('Deploy with Ansible') {
            steps {
                script {
                    // Export ECR Repo for Ansible
                    withEnv(["ECR_REPO_URL=${ECR_REPO}"]) {
                        sh "ansible-playbook -i ansible/inventory.aws_ec2.yml ansible/deploy.yml"
                    }
                }
            }
        }
    }
}
