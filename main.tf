provider "aws" {
  # version = "~> 2.62"
 region = "us-east-1"
}


resource "aws_security_group" "allow_ssh_rust" {
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

# EC2 instance

resource "aws_instance" "testbox" {
  ami             = data.aws_ami.amazon-linux-2.id
  instance_type   = "t2.2xlarge"
  key_name        = aws_key_pair.jm_alien.key_name
  security_groups = [aws_security_group.allow_ssh_rust.name]
  user_data       = <<EOF
#!/bin/bash
yum update -y
yum install -y --setopt=protected_multilib=false glibc.i686 libstdc++.i686
useradd rust
mkdir /home/rust/steamcmd; cd /home/rust/steamcmd
wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar zxf steamcmd_linux.tar.gz
chown -R rust:rust /home/rust/steamcmd
su rust -c "./steamcmd.sh +login anonymous +force_install_dir /home/rust/rustserver +app_update 258550 +quit"
EOF
}

# SSH public key for ec2-user

resource "aws_key_pair" "jm_alien" {
  key_name   = "jm_alien"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTurXRxVj0zBC4nSMY//w+G3a4RSIvU35tcAFJy4wq2y+v75xN9vOTk3BJm6gj14gOFFwl6boQ+zNkTMTebC/GF2JRU8/IzQcgFB/EMZhRU4KWwXhSccyFzk6XfKkg2UwSmY4bB/uLjq7e/d1xMOldFgrdzKPa/+FrDPhdsf8uerB6/VyBItBdLRZAqzw0sSBnxuRP9eS+UWtHA35tB0u8umF5oMVnN1IWE8xSrZorwiIujGYiGwC6GQFswqJk7GJvTQWxR3CVBMMmpGEXiiBCaeZLGgNR+cTbwW+6c3mhusG682KN7D6GMPy/bigUgBvv298TFHUUizfCeEWuU51z james@alien"
}


output "ip" {
  value = aws_instance.testbox.public_ip
}
