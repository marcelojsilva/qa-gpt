# resource "aws_security_group" "bastion" {
#   name        = "${var.app_name}-bastion"
#   description = "Security group for the bastion host"
#   vpc_id      = var.vpc_id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # Restrict this to your IP address for better security
#   }
# }

# resource "aws_instance" "bastion" {
#   ami           = data.aws_ami.amazon_linux_2.id
#   instance_type = "t2.micro"
#   key_name      = aws_key_pair.deployer.key_name

#   vpc_security_group_ids = [aws_security_group.bastion.id]
#   subnet_id              = var.public_subnet_id
#   associate_public_ip_address = true
#   tags = {
#     Name = "${var.app_name}-bastion"
#   }
# }
