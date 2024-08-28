#!/bin/bash
cd /home/ubuntu/chatbot || exit

if [ -f "$HOME/.bash_profile" ]; then
  source "$HOME/.bash_profile"
elif [ -f "$HOME/.bashrc" ]; then
  source "$HOME/.bashrc"
fi

rvm use 3.3.3
bundle install
yarn install
