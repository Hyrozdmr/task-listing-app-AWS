# Configure the AWS provider
provider "aws" {
  region = "eu-west-2"
}

# Configure the Terraform backend to use S3
terraform {
  backend "s3" {
    bucket = "hyr-fay-terraform-bucket"
    key    = "terraform/state.tfstate"
    region = "eu-west-2"
  }
}

# ECR Repository
resource "aws_ecr_repository" "my_ecr_repo" {
  name = "hyr-fay-ecr-repo"

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "IMMUTABLE"
}

# Elastic Beanstalk Application
resource "aws_elastic_beanstalk_application" "example_app" {
  name        = "hyr-fay-task-listing-app"
  description = "Task listing app"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "example_app_ec2_instance_profile" {
  name = "hyr-fay-task-listing-app-ec2-instance-profile"
  role = aws_iam_role.example_app_ec2_role.name
}


# IAM Role for EC2 Instances
resource "aws_iam_role" "example_app_ec2_role" {
  name = "hyr-fay-task-listing-app-ec2-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid = ""
      }
    ]
  })
}

#Create new Amazon RDS PostgreSQL database on AWS

resource "aws_db_instance" "rds_app" {
  allocated_storage    = 10
  engine               = "postgres"
  engine_version       = "14.12"
  instance_class       = "db.t3.micro"
  identifier           = "hyr-fay-example-app-prod"
  db_name              = "HyrFayExampleAppDataBase"
  username             = "root"
  password             = "hyrfayteam"
  skip_final_snapshot  = true
  publicly_accessible  = true
}

# Elastic Beanstalk Environment
resource "aws_elastic_beanstalk_environment" "example_app_environment" {
  name        = "hyr-fay-task-listing-app-environment"
  application = aws_elastic_beanstalk_application.example_app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.3.5 running Docker"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.example_app_ec2_instance_profile.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "hyr-fay"
  }
  
   # Set environment variables for the application
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_NAME"
    value     = aws_db_instance.rds_app.db_name
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_USER"
    value     = aws_db_instance.rds_app.username
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_PASSWORD"
    value     = aws_db_instance.rds_app.password
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_HOST"
    value     = aws_db_instance.rds_app.address
  }
}


resource "aws_iam_role_policy_attachment" "web_tier_policy_attachment" {
  role       = aws_iam_role.example_app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "multicontainer_docker_policy_attachment" {
  role       = aws_iam_role.example_app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_role_policy_attachment" "worker_tier_policy_attachment" {
  role       = aws_iam_role.example_app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}


resource "aws_iam_role_policy_attachment" "example_app_ec2_role_policy_attachment" {
  role       = aws_iam_role.example_app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# S3 Bucket for Dockerrun.aws.json
resource "aws_s3_bucket" "dockerrun_bucket" {
  bucket = "hyr-fay-dockerrun-bucket"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "Dockerrun Bucket"
    Environment = "Production"
  }
}
