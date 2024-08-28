#!/bin/bash
cd /home/ubuntu/chatbot || exit

source "$HOME/.bashrc"

rvm use 3.3.3
nvm use 20.15
bundle install
yarn install
