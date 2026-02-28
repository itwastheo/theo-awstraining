provider "aws" {
  region = var.region
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id 
  instance_type = var.instance_type
  key_name = var.instance_key
  subnet_id              = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.sg.id]

  tags = {
    Name = var.tags
  }

  volume_tags = {
    Name = var.tags
  } 
}
