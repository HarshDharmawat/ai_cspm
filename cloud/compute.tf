data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "auth" {
  key_name = "payvault-deployer-key"
  public_key = file(pathexpand(var.ssh_public_key_path))
}

# web SG: port 80 (HTTP), 8080 (App/Traefik), 22 (SSH)
resource "aws_security_group" "web_sg" {
  name = "payvault-web-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 80
    to_port  = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# database sg: port 5432 exposed to 0.0.0.0/0 (Intentional CSPM Flaw)
resource "aws_security_group" "db_sg" {
  name   = "payvault-db-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# web instance
resource "aws_instance" "web" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name = aws_key_pair.auth.key_name
  iam_instance_profile = aws_iam_instance_profile.web_profile.name

  # Intentional Flaw: Enable IMDSv1 for SSRF Credential Theft demonstration
  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "optional" # "optional" enables IMDSv1
  }

  tags = {
    Name = "payvault-web"
  }
}

# Database Instance
resource "aws_instance" "db" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  key_name = aws_key_pair.auth.key_name

  tags = {
    Name = "payvault-db"
  }
}