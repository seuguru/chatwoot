#!/bin/bash
sudo apt-get update
sudo apt-get -y install nginx
sudo apt-get install -y curl gpg build-essential postgresql-client libpq-dev

NODE_VERSION="20.15.0"
# Instalar Node.js 20.12.x se não estiver instalado
if ! node -v | grep -q "v20.12."; then
  curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

# Instalar NVM se não estiver instalado
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
fi

# Carregar NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Instalar e usar a versão necessária do Node.js
nvm install $NODE_VERSION
nvm use $NODE_VERSION

# Instalar Yarn se não estiver instalado
if ! yarn -v &>/dev/null; then
  npm install -g yarn
fi

# Verifica se o RVM está instalado

FILE="~/.rvm/scripts/rvm"

# Check if the file exists
if [ -f "$FILE" ]; then
  # Source the file
  source "$FILE"
else
  echo "File $FILE does not exist."
fi

if ! command -v rvm &>/dev/null; then
  echo "RVM não está instalado. Instalando agora..."

  # Importa as chaves GPG necessárias para instalar o RVM
  gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

  # Baixa e instala o RVM
  \curl -sSL https://get.rvm.io | bash -s stable

  # Carrega o RVM no shell atual
  source ~/.rvm/scripts/rvm
else
  echo "RVM já está instalado."
fi

source ~/.rvm/scripts/rvm
RUBY_VERSION="3.3.3"
if rvm list strings | grep -q "$RUBY_VERSION"; then
  echo "Ruby $RUBY_VERSION is already installed."
else
  echo "Ruby $RUBY_VERSION is not installed. Installing now..."
  rvm install "$RUBY_VERSION"
fi
