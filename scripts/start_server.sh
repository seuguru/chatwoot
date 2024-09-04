#!/bin/bash

cd /home/ubuntu/chatbot || exit
export RAILS_ENV=production
export PORT=4001
source ./scripts/set_version_manager.sh
source ./scripts/set_env.sh
rvm use 3.3.3
nvm use 20.15

bundle exec rails db:migrate
bundle exec rails assets:precompile
kill_process_on_port $PORT
kill_process_by_name "sidekiq"
bundle exec rails ip_lookup:setup && bin/rails server -p $PORT -e $RAILS_ENV >./log/production.log 2>&1 &
bundle exec rails ip_lookup:setup && bundle exec sidekiq -C config/sidekiq.yml -e $RAILS_ENV >./log/sidekiq.log 2>&1 &

echo "Deployment script completed."
