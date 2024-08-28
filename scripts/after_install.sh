#!/bin/bash
cd /home/ubuntu/chatbot || exit
source ./scripts/set_version_manager.sh

rvm use 3.3.3
nvm use 20.15
bundle install
yarn install
