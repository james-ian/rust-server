# setup
aws configure
git clone https://github.com/james-ian/rust-server.git
cp secret_vars.tf.template secret_vars.tf
vim secret_vars.tf
cp local_vars.tf.template local_vars.tf
vim local_vars.tf
terraform init

# build
make

# debug
make ssh
make tail

# destroy server
make destroy
