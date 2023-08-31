resource "aws_instance" "ec2_instance" {
  ami           = "ami-053b0d53c279acc90" # Ubuntu 22.04 LTS AMI ID
  instance_type = var.instance_type
  key_name      = var.key_pair_name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y software-properties-common
              sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
              sudo apt-get update -y
              sudo apt-get install -y grafana
              sudo systemctl enable grafana-server
              sudo systemctl start grafana-server
              EOF

  tags = {
    Name = "grafana-ec2-instance"
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_security_group_rule" "allow_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_http.id
}

resource "aws_security_group_rule" "allow_grafana" {
  type        = "ingress"
  from_port   = 3000
  to_port     = 3000
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_http.id
}

output "public_ip" {
  value = aws_instance.ec2_instance.public_ip
}


