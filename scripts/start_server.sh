#!/bin/bash
source "$HOME/.bashrc"
rvm use 3.3.3
nvm use 20.15
cd /home/ubuntu/chatbot || exit
sudo chown -R ubuntu:ubuntu /home/ubuntu/chatbot
sudo chmod -R u+w /home/ubuntu/chatbot
export RAILS_ENV=production
export PORT=4001
source ./scripts/set_env.sh
bundle exec rails db:migrate
bundle exec rails assets:precompile
bundle exec puma -C config/puma.rb
bundle exec rails ip_lookup:setup && bin/rails server -p $PORT -e $RAILS_ENV
lookup:setup && bundle exec sidekiq -C config/sidekiq.yml
