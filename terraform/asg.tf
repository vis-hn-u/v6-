resource "aws_launch_template" "app_lt" {
  name_prefix   = "careconnect-lt-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.kp.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker amazon-cloudwatch-agent
              service docker start
              usermod -a -G docker ec2-user

              # Login to ECR
              aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.app_repo.repository_url}

              # Pull and Run
              docker pull ${aws_ecr_repository.app_repo.repository_url}:latest
              docker run -d -p 80:3000 ${aws_ecr_repository.app_repo.repository_url}:latest

              # Configure CloudWatch Agent
              cat <<CONFIG > /opt/aws/amazon-cloudwatch-agent/bin/config.json
              {
                "agent": {
                  "metrics_collection_interval": 60,
                  "run_as_user": "root"
                },
                "metrics": {
                  "metrics_collected": {
                    "mem": {
                      "measurement": [
                        "mem_used_percent"
                      ],
                      "metrics_collection_interval": 60
                    },
                    "disk": {
                      "measurement": [
                        "used_percent"
                      ],
                      "resources": [
                        "/"
                      ],
                      "metrics_collection_interval": 60
                    }
                  }
                }
              }
              CONFIG

              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "CareConnect-ASG-Instance"
    }
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name                = "careconnect-asg"
  vpc_zone_identifier = module.vpc.public_subnets
  target_group_arns   = [aws_lb_target_group.app_tg.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}

resource "aws_autoscaling_policy" "cpu_policy" {
  name                   = "careconnect-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}
