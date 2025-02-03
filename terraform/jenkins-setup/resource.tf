
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250115"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

}

resource "aws_instance" "jenkins-server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  availability_zone      = var.availability_zone
  key_name               = aws_key_pair.jenkins_key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins-SG.id]
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "jenkins-server"
  }


  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/jenkins_key")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    script = "./installer.sh"

  }
}


resource "aws_security_group" "jenkins-SG" {
  tags = {
    Name = "jenkins-SG"
  }

  dynamic "ingress" {
    for_each = [22, 8080, 80, 443]
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "ALL"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_key_pair" "jenkins_key" {
  key_name   = "jenkins_key"
  public_key = file("${path.module}/jenkins_key.pub")
}

