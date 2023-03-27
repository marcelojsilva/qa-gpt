data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "instance" {
  name        = "${var.app_name}-instance"
  description = "Allow traffic for the Flask app instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
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
}

resource "aws_instance" "app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  key_name = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.instance.id]
  subnet_id              = var.subnet_id

  tags = {
    Name = "${var.app_name}-instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apt-transport-https ca-certificates curl software-properties-common
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
              add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              apt-get update
              apt-get install -y docker-ce
              curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              mkdir -p /app
              git clone https://github.com/marcelojsilva/qa-gpt.git /app
              cd /app/server
              ln -s /app/.env .env
              docker-compose up -d
              EOF
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.app_name}-deployer"
  public_key = file("~/.ssh/id_ed25519.pub")
#   public_key = file("<path/to/your/public_key.pem>")
}

output "instance_public_ip" {
  value = aws_instance.app.public_ip
}
