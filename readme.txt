# setup
aws configure
git clone https://github.com/james-ian/rust-server.git
cp secret_vars.tf.template secret_vars.tf
vim secret_vars.tf

# build
make

# debug
make ssh
make tail

# destroy server
make destroy

# rust console commands
connect server:port
god true
noclip
env.time 9
spawn minicopter.entity
spawn rhib
spawn scientist
teleportpos 0,0,0
printpos
heal
