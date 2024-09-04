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
nohup bundle exec rails ip_lookup:setup && bin/rails server -p $PORT -e $RAILS_ENV >./log/production.log 2>&1 &
nohup bundle exec rails ip_lookup:setup && bundle exec sidekiq -C config/sidekiq.yml -e $RAILS_ENV >./log/sidekiq.log 2>&1 &

echo "Checking if Rails server and Sidekiq are running..."
sleep 1m
echo "Start checking if Rails server and Sidekiq are running..."

if netstat -tuln | grep ":$PORT" >/dev/null; then
  echo "Rails server started successfully on port $PORT."
else
  echo "Failed to start Rails server on port $PORT."
  exit 1
fi

# Check if Sidekiq is running
if ps aux | grep sidekiq | grep -v grep >/dev/null; then
  echo "Sidekiq started successfully."
else
  echo "Failed to start Sidekiq."
  exit 1
fi

echo "Deployment script completed."
