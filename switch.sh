#!/bin/bash

# ================================
#
# Made by Ismail Drissi
#
# Github handle: @ismaildrs
#
# ================================

# ================================
# AppImage to Desktop Installer
# ------------------------------
# This script converts an AppImage into a desktop application.
# It moves the AppImage to a designated directory and creates a .desktop entry.
#
# Usage:
#   a2d [options] [AppImage_FilePath]
#
# Options:
#   -l, --local   Install the AppImage locally (~/.local/bin)
#   -g, --global  Install the AppImage globally (/opt)
#   -h, --help    Show this help message
# ================================

file="${@: -1}"  # file provided by the user

fileName="" # AppImage filename
filePath="" # Path to the file


options=("$@")
nbOpt=$(($#-2))

# Where the AppImage should be put
localAppPath="$HOME/.local/bin" 
globalAppPath="/opt" 

# Where the .desktop should be put
localFilePath="$HOME/.local/share/applications"
globalFilePath="/usr/share/applications"

# .desktop file variables
terminal=false # 
type="Application"
appName=$fileName
categories="" # App categories: Utility;Developpement...

label="AppImage → Desktop"

# Check user options
checkOptions(){
  if [[ "${options[0]}" == "--help" || "${options[0]}" == "-h" ]]; then
    showManual
    exit 0
  fi
  for i in $(seq 0 $nbOpt);
  do
    option="${options[i]}"
    echo $option
    case $option in
      -g | --global )
        state=true
      ;;
      -l | --local )
        state=false
      ;;
      * )
        echo "Unknown option: $option"
        echo "Wrong command structure, use --help to see usage"
        exit 1
      ;;
    esac
  done
}

# Show the app graphics
manageApp() {
  checkFile
  if [ -v state ]; then
    menu=$state
  else 
    menu=$(echo -e "local\nglobal" | fzf --header="Choose the location of your AppImage:" --disabled --reverse --height=10 --border --border-label="╢ $label ╟" --color=label:italic:white)
  fi
  case $menu in
    local)
      moveAppImageForLocal
      getUserInput
      createDesktopFileForLocal
      update-desktop-database "$localFilePath"
      ;;
    
    global)
      checkSudo # Check if command is run in sudo privileges
      moveAppImageForGlobal
      getUserInput
      createDesktopFileForGlobal
      update-desktop-database "$globalFilePath"
      ;;
  esac
  echo "Your ${appName} AppImage is added sucsessfully, you can access it from your desktop"
}

# Get the path to the AppImage From User
checkFile(){
  # Check if filepath is provided
  if [ -z "$file" ]; then 
    echo "File path is not provided, use --help to see usage"
    exit 1
  fi

  # Check if file exists
  if [ ! -f "$file" ]; then 
    echo "File does not exist"
    exit 1
  fi

  # Check if the file is an AppImage
  if ! file "$file" | grep -q '\.AppImage' ; then
    echo "File isn't an AppImage"
    exit 1
  fi

  fileNameTemp=$(basename "$file")
  fileName="${fileNameTemp%.*}"
}

checkSudo(){
  if [ $(id -u) -ne 0 ]; then
    echo "This option should be run with sudo, --help to se usage"
    exit 1  
  fi
}

showManual() {
  echo -e "\nUsage: a2d [options] [AppImage_FilePath]\n"
  echo -e "Options:"
  echo -e "  -l, --local   Install the AppImage locally (~/.local/bin)"
  echo -e "  -g, --global  Install the AppImage globally (/opt)"
  echo -e "  -h, --help    Show this help message\n"
  echo -e "-g or global options require 'sudo'\n"
  exit 0
}

# Move the AppImage to a safe place
moveAppImageForLocal(){
  chmod +x "$file"
  cp "$file" "$localAppPath"
  filePath="$localAppPath/$fileNameTemp" # new file path
}

moveAppImageForGlobal(){
  chmod +x "$file"
  cp "$file" "$globalAppPath"
  filePath="$globalAppPath/$fileNameTemp"
}

#
getUserInput(){
  local localAppName=$(echo "" | fzf --header="Give App Name(keep empty for default):" --print-query --height=10 --border --border-label="╢ $label ╟" --color=label:italic:white)
  if [ ! -z $localAppName ]; then appName=$localAppName;fi
}

# Create a .desktop file 
createDesktopFileForLocal(){
  desktopFilePath=$localFilePath/$fileName.desktop
  touch "$desktopFilePath"

  echo -e "[Desktop Entry]\nName=$appName\nExec=$filePath\nIcon=/path/to/icon.png\nTerminal=false\nType=Application\nCategories=Utility" > "$desktopFilePath"
}

createDesktopFileForGlobal(){
  desktopFilePath=$globalFilePath/$fileName.desktop
  touch "$desktopFilePath"
  echo -e "[Desktop Entry]\nName=$appName\nExec=$filePath\nIcon=/path/to/icon.png\nTerminal=false\nType=Application\nCategories=Utility" > "$desktopFilePath"
}

# Execute commands
checkOptions
manageApp


exit 0