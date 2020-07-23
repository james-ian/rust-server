provider "aws" {
  # version = "~> 2.62"
 region = "us-east-1"
}

resource "aws_security_group" "allow_all" {
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# AMI to use for EC2

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# rcon password

resource "aws_secretsmanager_secret" "rcon_pw" {
  name = "rcon_pw"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "rcon_pw" {
  secret_id     = aws_secretsmanager_secret.rcon_pw.id
  secret_string = var.rcon_password
}

# Policy to allow EC2 to read rcon password from SecretsManager

resource "aws_iam_role" "ec2_rcon_readonly_role" {
  name = "ec2_rcon_readonly_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_rcon_readonly_role_attachment" {
  role       = aws_iam_role.ec2_rcon_readonly_role.name
  policy_arn = aws_iam_policy.rcon_readonly_policy.arn
}

resource "aws_iam_policy" "rcon_readonly_policy" {
  name        = "rcon_readonly_policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:secretsmanager:us-east-1:474145379133:secret:rcon_*"
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "rcon_readonly_profile" {
  name = "rcon_readonly_profile"
  role = aws_iam_role.ec2_rcon_readonly_role.name
}

# EC2 instance

resource "aws_instance" "rustserver" {
  ami             = data.aws_ami.amazon-linux-2.id
  instance_type   = "t2.2xlarge"
  key_name        = aws_key_pair.jm_alien.key_name
  security_groups = [aws_security_group.allow_all.name]
  user_data       = file("scripts/install-server")
  iam_instance_profile = aws_iam_instance_profile.rcon_readonly_profile.name
}

# SSH public key for ec2-user

resource "aws_key_pair" "jm_alien" {
  key_name   = "jm_alien"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTurXRxVj0zBC4nSMY//w+G3a4RSIvU35tcAFJy4wq2y+v75xN9vOTk3BJm6gj14gOFFwl6boQ+zNkTMTebC/GF2JRU8/IzQcgFB/EMZhRU4KWwXhSccyFzk6XfKkg2UwSmY4bB/uLjq7e/d1xMOldFgrdzKPa/+FrDPhdsf8uerB6/VyBItBdLRZAqzw0sSBnxuRP9eS+UWtHA35tB0u8umF5oMVnN1IWE8xSrZorwiIujGYiGwC6GQFswqJk7GJvTQWxR3CVBMMmpGEXiiBCaeZLGgNR+cTbwW+6c3mhusG682KN7D6GMPy/bigUgBvv298TFHUUizfCeEWuU51z james@alien"
}


output "ip" {
  value = aws_instance.rustserver.public_ip
}
