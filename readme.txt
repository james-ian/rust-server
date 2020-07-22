# setup
aws configure
git clone https://github.com/james-ian/rust-server.git

# build
make

# debug
make ssh
make tail

# destroy server
make clean
