#!/bin/bash

file=$1
fileName="" # AppImage filename
filePath=""
localAppPath="~/.local/bin"
systemWideAppPath="/opt"
localFilePath="~/.local/share/applications/" # for .desktop files in local mode
systemWideFilePath="/usr/share/applications/" # // in system-wide mode

terminal=false # 
type="Application"
categories="" # App categories: Utility;Developpement...


# Show the app graphics
hello() {
  clear
  echo -e "\e[1;36m$(figlet -f small 'AppImage → Desktop' | lolcat)\e[0m"
  echo -e "\e[1;32mReduce the burden of manual setup!\e[0m" | lolcat
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
}


# Give user options: Global or Local AppImage
userOptions(){

}

# Move the AppImage to a safe place
moveAppImage($option){
  chmod +x "$file"
  if [[$option -e "local"]]; then

    mv "$file" "$localAppPath"
    filePath="$localAppPath/$file"
    
  else if [[$option -e "system-wide"]]; then
    sudo mv "$file" /opt/
  fi 
}

# Create a .desktop file 
createDesktopFile($option){
  if [[ $option -e "local" ]]; then
    desktopFilePath=$localFilePath/$fileName.desktop
    touch "$desktopFilePath"
    echo "Name=$filename
          Exec=$
          Icon=/path/to/icon.png
          Terminal=false
          Type=Application
          Categories=Utility;
          StartupWMClass=your_app
          " >> "$desktopFilePath"
}

# Update the apps database
updateAppDatabase(){

}

# Execute commands
hello
checkFile
