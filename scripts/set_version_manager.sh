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

kill_process_on_port() {
  PORT=$1
  PID=$(lsof -t -i:$PORT)
  if [ ! -z "$PID" ]; then
    echo "Matando o processo existente na porta $PORT com PID $PID"
    kill -9 $PID
  fi
}

kill_process_by_name() {
  PROCESS_NAME=$1
  PIDS=$(pgrep -f $PROCESS_NAME)
  if [ ! -z "$PIDS" ]; then
    echo "Matando os processos existentes com o nome $PROCESS_NAME"
    kill -9 $PIDS
  fi
}
