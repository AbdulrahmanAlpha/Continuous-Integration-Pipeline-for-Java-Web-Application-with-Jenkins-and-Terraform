## Overview

This project aims to set up a continuous integration pipeline for a Java web application using Jenkins and Terraform. The pipeline automates the build, test, and deployment process, including running unit tests, integration tests, and deploying to a staging environment. The Terraform code creates an EC2 instance with a security group and key pair, and provisions it with Jenkins. The Jenkins code defines a pipeline that builds, tests, and deploys the Java web application. By automating the development process, this project streamlines the development workflow and ensures consistent and reliable results.

## Prerequisites

Before starting, make sure you have the following:

- A Java web application codebase hosted in a version control system like Git
- An AWS account
- Terraform installed on your local machine
- A Jenkins instance installed and configured

## Terraform Code

The Terraform code creates an EC2 instance with a security group and key pair, and provisions it with Jenkins. Here are the steps to create the EC2 instance:

1. Create a new directory for your Terraform code and navigate to it.
2. Create a new file called `main.tf` and paste the following code:

```terraform
# Define the provider
provider "aws" {
  region = "us-west-2"
}

# Define the security group
resource "aws_security_group" "jenkins" {
  name = "jenkins-sg"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define the key pair
resource "aws_key_pair" "jenkins" {
  key_name   = "jenkins-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Define the EC2 instance
resource "aws_instance" "jenkins" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.jenkins.key_name
  security_groups = [aws_security_group.jenkins.name]

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y java-1.8.0-openjdk",
      "sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key",
      "sudo yum install -y jenkins",
      "sudo systemctl start jenkins",
      "sudo systemctl enable jenkins"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host        = aws_instance.jenkins.public_ip
    }
  }

  tags = {
    Name = "jenkins"
  }
}
```

This Terraform code creates an EC2 instance with an Amazon Linux 2 AMI, a security group that allows SSH and HTTP traffic, and a key pair. It then provisions the instance with Java and Jenkins using the `remote-exec` provisioner.

3. Initialize the Terraform project:
```bash
terraform init
```

4. Preview the changes:
```bash
terraform plan
```

5. Apply the changes:
```bash
terraform apply
```

## Jenkins Code

The Jenkins code defines a pipeline that builds, tests, and deploys the Java web application. Here are the steps to create the Jenkins pipeline:

1. Open your Jenkins instance and create a new job.
2. Select "Pipeline" as the job type and give it a name.
3. In the "Pipeline" section, select "Pipeline script" as the definition.
4. Paste the following code in the script editor:

```jenkinsfile
pipeline {
  agent any

  stages {
    stage('Build') {
      steps {
        sh 'mvn clean package'
      }
    }

    stage('Unit Test') {
      steps {
        sh 'mvn test'
      }
    }

    stage('Integration Test') {
      steps {
        sh 'mvn verify'
      }
    }

    stage('Deploy to Staging') {
      steps {
        sh 'ssh user@staging-server "cd /path/to/deploy && ./deploy.sh"'
      }
    }
  }
}
```

This Jenkins code defines a pipeline with four stages: "Build", "Unit Test", "Integration Test", and "Deploy to Staging". The pipeline uses Maven to build and test the Java web application, and then deploys it to astaging server using SSH.

5. Save the Jenkins job and run it to test the pipeline.

## Conclusion

By setting up a continuous integration pipeline for your Java web application using Jenkins and Terraform, you can automate the build, test, and deployment process, ensuring consistent and reliable results. The Terraform code creates an EC2 instance with a security group and key pair, and provisions it with Jenkins. The Jenkins code defines a pipeline that builds, tests, and deploys the Java web application. With this pipeline in place, you can focus on developing your application and trust that the pipeline will handle the rest.   