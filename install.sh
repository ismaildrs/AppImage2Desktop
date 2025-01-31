#!/bin/bash

cp ./switch.sh /bin
echo "alias a2d='switch.sh'" >> ~/.bashrc


sudo apt update
sudo apt install fzf tmux file desktop-file-utils