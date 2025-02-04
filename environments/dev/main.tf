# Terraform-Konfiguration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"  # Definiert die AWS-Provider-Version
    }
  }
}

# AWS Provider konfigurieren
provider "aws" {
  region = "eu-central-1"  # Region: Frankfurt
}

# Virtual Private Cloud (VPC) erstellen
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"  # Netzwerkbereich für die VPC

  tags = {  # Tags zur besseren Identifikation der Ressource
    Name        = "Hauptnetzwerk"
    Environment = "Entwicklung"
  }
}

# Öffentliches Subnetz erstellen
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id  # Verknüpft das Subnetz mit der VPC
  cidr_block        = "10.0.1.0/24"    # Netzwerkbereich für das Subnetz
  availability_zone = "eu-central-1a" # Verfügbarkeit in einer spezifischen Zone

  tags = {
    Name = "Öffentliches Subnetz"
  }
}

# Sicherheitsgruppe für den Web Server
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Erlaubt HTTP und SSH Verkehr"
  vpc_id      = aws_vpc.main.id

  # Eingehender Traffic (Ingress) erlauben
  ingress {
    from_port   = 80      # HTTP-Port
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Zugriff von überall erlauben
  }

  ingress {
    from_port   = 22      # SSH-Port
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ausgehender Traffic (Egress) erlauben
  egress {
    from_port   = 0       # Alle Ports erlaubt
    to_port     = 0
    protocol    = "-1"    # Alle Protokolle erlaubt
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instanz erstellen
resource "aws_instance" "web_server" {
  ami           = "ami-0f7204385566b32d0"   # Amazon Linux AMI (Region-spezifisch)
  instance_type = "t2.micro"               # Kleinste Instanzgröße (kostenfrei in Free Tier)
  subnet_id     = aws_subnet.public.id     # Subnetz, in dem die Instanz läuft

  tags = {
    Name        = "Web Server"
    Environment = "Entwicklung"
  }

  security_groups = [aws_security_group.web_sg.name] # Sicherheitsgruppe zuweisen
}
