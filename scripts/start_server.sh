#!/bin/bash
source ~/.rvm/scripts/rvm
cd /home/ubuntu/chatbot || exit
export RAILS_ENV=production
export PORT=4001
source ./scripts/set_env.sh
bundle exec rails db:migrate
bundle exec rails assets:precompile
bundle exec puma -C config/puma.rb
bundle exec rails ip_lookup:setup && bin/rails server -p $PORT -e $RAILS_ENV
lookup:setup && bundle exec sidekiq -C config/sidekiq.yml
