#!/bin/bash
if [ -f "$HOME/.bash_profile" ]; then
  source "$HOME/.bash_profile"
elif [ -f "$HOME/.bashrc" ]; then
  source "$HOME/.bashrc"
fi

# Load RVM into a shell session as a function
if [ -s "$HOME/.rvm/scripts/rvm" ]; then
  source "$HOME/.rvm/scripts/rvm"
else
  echo "RVM is not installed."
  exit 1
fi

# Load NVM into a shell session as a function
if [ -s "$HOME/.nvm/nvm.sh" ]; then
  source "$HOME/.nvm/nvm.sh"
else
  echo "NVM is not installed."
  exit 1
fi

sudo chown -R ubuntu:ubuntu /home/ubuntu/chatbot
sudo chmod -R u+w /home/ubuntu/chatbot

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
