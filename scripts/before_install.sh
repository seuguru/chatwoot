#!/bin/bash
sudo apt-get update
sudo apt-get -y install nginx
sudo apt-get install -y curl gpg build-essential

if ! rvm -v &>/dev/null; then
  gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  \curl -sSL https://get.rvm.io | bash -s stable
fi

source ~/.rvm/scripts/rvm

if ! rvm list strings | grep -q "ruby-3.3.3"; then
  rvm install 3.3.3
else
  echo "Ruby 3.3.3 is already installed."
fi
