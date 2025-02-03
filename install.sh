#!/bin/bash

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check sudo privileges
checkSudo() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}Error: This script must be run with sudo privileges.${NC}"
        echo "Use: sudo ./install.sh"
        echo "Use: ./install.sh --help for usage information"
        exit 1
    fi
}

# Function to show help
showHelp() {
    echo "Usage: sudo ./install.sh [OPTIONS]"
    echo
    echo "Options:"
    echo "  --help     Show this help message"
    echo
    echo "Installs switch.sh command and required dependencies"
    exit 0
}

# Check if --help is provided
if [[ "$1" == "--help" ]]; then
    showHelp
fi

# Check sudo privileges
checkSudo

# Check if command is already installed
if [[ $(ls /bin/ | grep switch.sh) ]]; then
    echo -e "${YELLOW}Warning: Command already installed.${NC}"
    exit 1
fi

# Function to show progress bar
show_progress() {
    local duration=$1
    local width=50
    local percent=0
    
    for ((i=0; i<=width; i++)); do
        percent=$((i * 100 / width))
        printf "\r["
        printf "%0.s#" $(seq 1 $i)
        printf "%0.s " $(seq 1 $((width-i)))
        printf "] %d%%" $percent
        sleep $duration
    done
    printf "\n"
}

# Copy the script
echo -e "${YELLOW}Copying switch.sh to /bin...${NC}"
cp ./switch.sh /bin/
chmod +x /bin/switch.sh

# Update .bashrc
echo "alias a2d='switch.sh'" >> ~/.bashrc
source $HOME/.bashrc

# Show installation progress
echo -e "${YELLOW}Installing dependencies...${NC}"
show_progress 0.05

# Update package lists
echo -e "${YELLOW}Updating package lists...${NC}"
apt update &>/dev/null

# Install dependencies with progress
echo -e "${YELLOW}Installing required packages...${NC}"
apt install -y fzf tmux file desktop-file-utils < /dev/null

# Final success message
echo
echo -e "${GREEN}╔════════════════════════════════════╗${NC}"
echo -e "${GREEN}║    Installation Completed! 🎉      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════╝${NC}"
echo
echo -e "${YELLOW}To get started, try:${NC}"
echo -e "  ${GREEN}a2d --help${NC}"