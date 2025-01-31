#!/bin/bash

file="${@: -1}"  # file provided by the user

fileName="" # AppImage filename
filePath="" # Path to the file


options=@
nbOpt=$(($#+1))

echo $nbOpt

# Where the AppImage should be put
localAppPath="$HOME/.local/bin" 
globalAppPath="/opt" 

# Where the .desktop should be put
localFilePath="$HOME/.local/share/applications"
globalFilePath="/usr/share/applications"

# .desktop file variables
terminal=false # 
type="Application"
categories="" # App categories: Utility;Developpement...

# Check user options
checkOptions(){
  for i in $(seq 1 $nbOpt);
  do
    option="${!i}"
    echo $option
    case $option in
      -h | --help )
        showManual
        exit 0
      ;;
      -g | --global )
        state=true
      ;;
      -l | --local )
        state=false
      ;;
      * )
        echo "Unknown option: $option"
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
    menu=$(echo -e "local\nglobal" | fzf-tmux --header="AppImage → Desktop" --reverse)
  fi
  case $menu in
    local)
      moveAppImageForLocal
      createDesktopFileForLocal
      update-desktop-database "$localFilePath"
      ;;
    
    global)
      checkSudo # Check if command is run in sudo privileges
      moveAppImageForGlobal
      createDesktopFileForGlobal
      update-desktop-database "$globalFilePath"
      ;;
  esac
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

showManual(){
  echo -e "a2d or switch.sh: Transform AppImage to Desktop Apps"
  echo -e "This is not more than a bash script to create a desktop file and move you AppImage into a safe place :)"
  echo -e "Usage:\na2d [options] [FilePath.sh]\na2d --local [FilePath.sh]\na2d --global [FilePath.sh]" 
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

# # Create a .desktop file 
createDesktopFileForLocal(){
  desktopFilePath=$localFilePath/$fileName.desktop
  touch "$desktopFilePath"
  echo -e "[Desktop Entry]\nName=$fileName\nExec=$filePath\nIcon=/path/to/icon.png\nTerminal=false\nType=Application\nCategories=Utility" > "$desktopFilePath"
}

createDesktopFileForGlobal(){
  desktopFilePath=$globalFilePath/$fileName.desktop
  touch "$desktopFilePath"
  echo -e "[Desktop Entry]\nName=$fileName\nExec=$filePath\nIcon=/path/to/icon.png\nTerminal=false\nType=Application\nCategories=Utility" > "$desktopFilePath"
}

# Execute commands
checkOptions
manageApp


exit 0