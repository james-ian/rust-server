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
