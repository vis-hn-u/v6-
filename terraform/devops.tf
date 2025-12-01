resource "aws_security_group" "devops_sg" {
  name_prefix = "devops-sg-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Jenkins"
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SonarQube"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "devops_server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.kp.key_name
  subnet_id     = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.devops_sg.id]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = base64encode(<<-EOF
              #!/bin/bash
              # 1. Create Swap Space (2GB) to prevent OOM
              dd if=/dev/zero of=/swapfile bs=128M count=16
              chmod 600 /swapfile
              mkswap /swapfile
              swapon /swapfile
              echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

              # 2. Install Dependencies
              yum update -y
              yum install -y git java-17-amazon-corretto-devel docker python3-pip
              
              # 3. Install Ansible
              pip3 install ansible boto3 botocore

              # 4. Start Docker
              service docker start
              usermod -a -G docker ec2-user
              chmod 666 /var/run/docker.sock

              # 5. Run SonarQube (Docker)
              # Use a smaller image or limit memory if possible, but swap helps
              docker run -d --name sonarqube -p 9000:9000 sonarqube:community

              # 6. Install Jenkins
              wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
              yum upgrade -y
              yum install -y jenkins
              systemctl enable jenkins
              systemctl start jenkins
              EOF
  )

  tags = {
    Name = "DevOps-Server"
  }
}

output "devops_server_ip" {
  value = aws_instance.devops_server.public_ip
}
