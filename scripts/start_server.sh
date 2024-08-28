#!/bin/bash

if [ -f "$HOME/.bash_profile" ]; then
  source "$HOME/.bash_profile"
elif [ -f "$HOME/.bashrc" ]; then
  source "$HOME/.bashrc"
fi
rvm use 3.3.3
nvm use 20.15
cd /home/ubuntu/chatbot || exit
export RAILS_ENV=production
export PORT=4001
source ./scripts/set_env.sh
bundle exec rails db:migrate
bundle exec rails assets:precompile
bundle exec puma -C config/puma.rb
bundle exec rails ip_lookup:setup && bin/rails server -p $PORT -e $RAILS_ENV
lookup:setup && bundle exec sidekiq -C config/sidekiq.yml
