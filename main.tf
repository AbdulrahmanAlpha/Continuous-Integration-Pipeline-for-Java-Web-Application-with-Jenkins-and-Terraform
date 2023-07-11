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