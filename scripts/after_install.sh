#!/bin/bash
cd /home/ubuntu/chatbot || exit
rvm use 3.3.3
bundle install
yarn install
