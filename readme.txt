
### start ec2 instance

aws configure
git clone TBD
terraform init
terraform plan
terraform apply -no-color -auto-approve | tee terraform.out
ssh -oStrictHostKeyChecking=false -l ec2-user "$(tail terraform.out | awk '/^ip = / { print $3 }')"

### cleanup

terraform destroy -auto-approve


### install rust server
#!/bin/bash

set -o errexit

# https://developer.valvesoftware.com/wiki/SteamCMD#Linux

# steamcmd pre-reqs
sudo yum install -y --setopt=protected_multilib=false glibc.i686 libstdc++.i686

# install steamcmd
mkdir steamcmd; cd steamcmd
wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar zxf steamcmd_linux.tar.gz
./steamcmd.sh \
	 +login anonymous \
	 +force_install_dir /home/ec2-user/rustserver \
	 +app_update 258550 \
	 +quit

### start rust server

cd ~/rustserver
nohup \
 ./RustDedicated \
 -batchmode \
 +server.port 28015 \
 +server.level "Procedural Map" \
 +server.seed 1234 \
 +server.worldsize 4000 \
 +server.maxplayers 10  \
 +server.hostname "ABC123 TEST SERVER" \
 +server.description "my rust server" \
 +server.url "http://yourwebsite.com" \
 +server.headerimage "http://yourwebsite.com/serverimage.jpg" \
 +server.identity "server1"
