#!/bin/bash
yum update -y
yum install -y docker git
service docker start
usermod -a -G docker ec2-user

# Clone the repository
cd /home/ec2-user
git clone https://github.com/vis-hn-u/v6-.git app
cd app

# Build and run the container
docker build -t careconnect .
docker run -d -p 80:3000 careconnect
