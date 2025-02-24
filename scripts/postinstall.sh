#!/usr/bin/env bash

#set -x

unset npm_config_prefix

# flush any partial
read -p "Enter to continue" -r
REPLY=""

read_input() {
  if [ -t 0 ]; then  # Check if it's running interactively
    read -p "$1" -r REPLY
  else
    read -r REPLY
    REPLY=${REPLY:0:1}  # Take the first character of the piped input
  fi
  echo  # Add a newline for readability
  echo
}


if [[ "$(uname -s)" == "Darwin" ]]; then
  if [[ "$(arch)" != "i386" ]]; then
    >&2 echo "Please run this script under Rosetta (i386 architecture)."
    exit 1
  fi
fi

echo 
echo
read_input "Want to run setup_machine script? (you only need to do this the first time you install BG, or when you update new version) y/n " 
echo
echo
if [[ ! $REPLY =~ ^[Yy]$ ]];
then
  echo "Not running full setup...Just doing npm install..."
else 
  echo "Running full setup..."
  bash ./scripts/setup_machine.sh
fi

mkdir -p src/public/voodoo/assets/icons

echo "Installing packages for zombie lord..."
cd src/zombie-lord 
npm i    
npm audit fix
echo "Installing packages for client..."
cd ../public/voodoo
npm i    
npm audit fix
# cd ../../endbacker
# npm i    
echo "Installing packages for custom chrome launcher..."
cd ../../zombie-lord/custom-launcher
npm i    
npm audit fix
cd ../../

echo "Installing packages for audio service..."
cd services/instance/parec-server
npm i    
npm audit fix
cd ../

#Not installing pptr console and websocket chat 
  #echo "Installing packages for pptr console service..."
  #cd pptr-console-server
  #export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=True
  #npm i    
  #npm audit fix
  #
  #rm -rf node_modules/puppeteer/.local-chromium
  #
  #echo "Installing packages for real time chat service..."
  #cd websocket_chat_app_homework
  #npm i
  #npm audit fix
  #cd ../
  #cd ../

echo "Installing packages for remote devtools service..."
cd ../pool/crdp-secure-proxy-server
npm i
npm audit fix

echo "Installing packages for secure document viewer..."
cd ../chai
npm i
npm audit fix

echo
read_input "Do you want to skip the secure document viewer? (lengthy install because of all the fonts and TeX related packages) y/n "

if [[ "$IS_DOCKER_BUILD" = "true" ]] || [[ "$REPLY" =~ ^[Yy]$ ]]; then
  echo "Skipping doc viewer install"
else
  echo "Installing OS dependencies for secure document viewer..."
  ./scripts/setup.sh
fi

cd ../../../../

USE_FLASH=$(node ./src/show_useflash.js);
if [[ $USE_FLASH != "false" ]]; then
  which apt-get && sudo apt-get install jq || winget install jq || brew install jq
  ./scripts/download_ruffle.sh
fi

which pm2 || npm i -g pm2@latest || sudo npm i -g pm2@latest

npm i --save-exact esbuild@latest

npm audit fix

echo Done post install

