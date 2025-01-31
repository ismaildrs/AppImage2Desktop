#!/bin/bash
checkSudo(){
  if [ $(id -u) -ne 0 ]; then
    echo "This script should be run with sudo, --help to se usage"
    exit 1  
  fi
}

checkSudo # check sudo priviliges

if [[ $(ls /bin/ | grep switch.sh) ]]; then
  echo "Warning: command aldready installed"
  exit 1;
fi

cp ./switch.sh /bin

echo "alias a2d='switch.sh'" >> ~/.bashrc
source $HOME/.bashrc

sudo apt update
sudo apt install fzf tmux file desktop-file-utils