#
# Written by Ahmad Al Zayed - Feb 12, 2029
#
# Last update Feb 25, 2020 
#

defaultConfig (){
	NEWCONFIG="$(dirname "$(realpath "$0")")/.SFSCextractorrc" 
	cat <<"EOF" > $NEWCONFIG
# e.g. your browsers default download folder
DOWNLOAD_FOLDER=~/Downloads

# the folder with your cases
CASES_FOLDER=/$HOME/SFSC 

# loglevel 1=errors 2=verbose
LOGLEVEL=1

# fix tar archive rights 1=yes 0=no
FIX_ARCHIVE_RIGHTS=1
EOF 
} #end defaultConfig 

install () { 
  rpm -q inotify-tools 2> /dev/null 
  [[ $? -eq 1 ]] && {
    echo "Installing inotify-tools ..." 
    sudo zypper install -y inotify-tools
  } 
} #end install 

config () {

  CONFIG="$HOME/.SFSCextractorrc" 
  NEWCONFIG="$(dirname "$(realpath "$0")")/.SFSCextractorrc" 

  # check if file exist to not overwrite
  # the user settings on update
  [[ ! -f $CONFIG ]] && {
  	echo "Creating $CONFIG ..." 
	  cp -p $NEWCONFIG $CONFIG 
  } || {
	  #just add new options
	  grep "^FIX_ARCHIVE_RIGHTS" ~/.SFSCextractorrc || 
      echo -e "\n# fix tar archive rights 1=yes 0=no\nFIX_ARCHIVE_RIGHTS=1\n" >> ~/.SFSCextractorrc	
	}
} #end config 

systemd () {
  echo "Copying SFSCextractor.sh to /usr/bin/" 
  sudo cp $(dirname "$(realpath "$0")")/SFSCextractor.sh /usr/bin/
  sudo chmod 755 /usr/bin/SFSCextractor.sh
  
  echo "Copying the startscript to global systemd users directory..." 
  sudo cp $(dirname "$(realpath "$0")")/SFSCextractor@.service /etc/systemd/user/
  sudo chmod 744 /etc/systemd/user/SFSCextractor@.service 
  
  echo "reload systemd at userspace" 
  systemctl --user daemon-reload
  
  echo "create a instance from the service for your user" 
  mkdir -p ~/.config/systemd/user
  systemctl --user enable SFSCextractor@$USER.service
  
  echo "start the service ..."
  systemctl --user restart SFSCextractor@$USER.service
  
  echo "Let us check ..." 
  systemctl --user status SFSCextractor@$USER.service
} #end systemd 

main (){
  install ; defaultConfig; config ; systemd 
}

main 
