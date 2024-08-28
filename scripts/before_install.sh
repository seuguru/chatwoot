#!/bin/bash
sudo apt-get update
sudo apt-get -y install nginx
sudo apt-get install -y curl gpg build-essential

if ! rvm -v &>/dev/null; then
  gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  \curl -sSL https://get.rvm.io | bash -s stable
fi

source ~/.rvm/scripts/rvm
RUBY_VERSION="3.3.3"
if rvm list strings | grep -q "$RUBY_VERSION"; then
  echo "Ruby $RUBY_VERSION is already installed."
else
  echo "Ruby $RUBY_VERSION is not installed. Installing now..."
  rvm install "$RUBY_VERSION"
fi
