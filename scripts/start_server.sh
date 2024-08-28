#!/bin/bash
source ./scripts/set_version_manager.sh

rvm use 3.3.3
nvm use 20.15

cd /home/ubuntu/chatbot || exit
export RAILS_ENV=production
export PORT=4001
source ./scripts/set_env.sh

bundle exec rails db:migrate
bundle exec rails assets:precompile
kill_process_on_port $PORT
kill_process_by_name "sidekiq"
bundle exec rails ip_lookup:setup && bin/rails server -p $PORT -e $RAILS_ENV
bundle exec rails ip_lookup:setup && bundle exec sidekiq -C config/sidekiq.yml
