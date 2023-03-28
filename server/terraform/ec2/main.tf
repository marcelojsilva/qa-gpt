variable "app_name" {
  type        = string
  description = "The name of the application"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to deploy the infrastructure in"
}

variable "subnet_id" {
  type        = string
  description = "The private subnet ID to deploy the EC2 instance in"
}

variable "public_subnet_id" {
  description = "The public subnet ID where the bastion host will be launched"
  type        = string
}

variable "public_key_path" {
  type        = string
  description = "The path to the public key to use for SSH access"
}

variable "db_url" {
  type        = string
  description = "The database URL"
}

variable "openai_api_key" {
  type        = string
  description = "The OpenAI API key"
}

variable "pinecone_api_key" {
  type        = string
  description = "The Pinecone API key"
}

# data "aws_ami" "amazon_linux_2" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }

#   owners = ["amazon"]
# }

resource "aws_instance" "main" {
  ami           = "ami-00c39f71452c08778"
#   ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"

  key_name               = aws_key_pair.deployer.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.app.id]
  associate_public_ip_address = true
  
  user_data = <<EOF
#!/bin/bash
yum update -y
yum install -y git docker
yum install -y docker
yum install -y libxcrypt-compat
systemctl enable docker
systemctl start docker
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
cd /root
git clone https://github.com/marcelojsilva/qa-gpt.git
cd qa-gpt/server
echo "DATABASE_URL=${var.db_url}" >> .env
echo "OPENAI_API_KEY=${var.openai_api_key}" >> .env
echo "PINECONE_API_KEY=${var.pinecone_api_key}" >> .env
[Unit]
Description= Docker Compose Startup Service
Requires=docker.service
After=docker.service

echo "[Service]" >> /etc/systemd/system/myapp.service
echo "Type=oneshot" >> /etc/systemd/system/myapp.service
echo "RemainAfterExit=yes" >> /etc/systemd/system/myapp.service
echo "WorkingDirectory=/root/qa-gpt/server" >> /etc/systemd/system/myapp.service
echo "ExecStart=/usr/bin/docker-compose up -d" >> /etc/systemd/system/myapp.service
echo "ExecStop=/usr/bin/docker-compose down" >> /etc/systemd/system/myapp.service
echo "TimeoutStartSec=0" >> /etc/systemd/system/myapp.service
systemctl enable myapp.service
EOF
  
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.public_key_path)
    host        = self.private_ip
  }

  tags = {
    Name = "${var.app_name}-ec2"
  }
}

resource "aws_security_group" "app" {
  name        = "${var.app_name}-app-sg"
  description = "Allow inbound traffic to the EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-app-sg"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.app_name}-deployer"
  public_key = file(var.public_key_path)
}

output "security_group_id" {
  value = aws_security_group.app.id
}

output "ec2_public_ip" {
  description = "The public IP address of the bastion host"
  value       = aws_instance.main.public_ip
}

# output "bastion_public_ip" {
#   description = "The public IP address of the bastion host"
#   value       = aws_instance.bastion.public_ip
# }
