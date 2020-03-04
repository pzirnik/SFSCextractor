#
# Written by Ahmad Al Zayed - Feb 12, 2029
#
# Last update Feb 25, 2020 
#

install () { 
  echo "Check if inotify-tools installed ..."
  ${RPM} -q inotify-tools >/dev/null 2>&1 
  [[ $? -eq 1 ]] && {
    echo "  Not found, try Installing inotify-tools ..." 
    ${SUDO} zypper install -y inotify-tools
  } 
} #end install 

config () {

  CONFIG="$HOME/.SFSCextractorrc" 
  NEWCONFIG=$(mktemp) 

  # check if file exist to not overwrite
  # the user settings on update
  [[ ! -f $CONFIG ]] && {
  	echo "No previous configuration found, creating ${CONFIG} ..." 
    NEWCONFIG=$(mktemp)
cat <<EOF >"${NEWCONFIG}"
# e.g. your browsers default download folder
DOWNLOAD_FOLDER=~/Downloads

# the folder with your cases
CASES_FOLDER=$HOME/SFSC 

# loglevel 1=errors 2=verbose
LOGLEVEL=1

# fix tar archive rights 1=yes 0=no
FIX_ARCHIVE_RIGHTS=1
EOF
	  cp -p ${NEWCONFIG} ${CONFIG} 
    rm -f ${NEWCONFIG}
  } || {
	  #just add new options
    echo "Previous configuration found, checking options ..."
	  grep "^FIX_ARCHIVE_RIGHTS" ${CONFIG} >/dev/null || {
      echo -e "\n# fix tar archive rights 1=yes 0=no\nFIX_ARCHIVE_RIGHTS=1\n" >> ${CONFIG}	
      echo "  added option FIX_ARCHIVE_RIGHTS=1"
    }
	}
} #end config 

systemd () {
  ${RPM} -q SFSCextractor >/dev/null 2>&1
  [[ $? -eq 1 ]] && {
    echo "Copying SFSCextractor.sh to /usr/bin/" 
    ${SUDO} cp $(dirname "$(realpath "$0")")/SFSCextractor.sh /usr/bin/
    ${SUDO} chmod 755 /usr/bin/SFSCextractor.sh
  
    echo "Copying the startscript to global systemd users directory..." 
    ${SUDO} cp $(dirname "$(realpath "$0")")/SFSCextractor@.service /etc/systemd/user/
    ${SUDO} chmod 744 /etc/systemd/user/SFSCextractor@.service 
  
  }
  echo "reload systemd at userspace" 
  ${SYSTEMCTL} --user daemon-reload
  
  echo "create a instance from the service for user $USER" 
  mkdir -p ~/.config/systemd/user
  ${SYSTEMCTL} --user enable SFSCextractor@$USER.service
  
  echo "start the service ..."
  ${SYSTEMCTL} --user restart SFSCextractor@$USER.service
  
  echo "Let us check ..." 
  ${SYSTEMCTL} --user status SFSCextractor@$USER.service
} #end systemd 

main (){
  install ; config ; systemd 
}

RPM=$(which rpm)
SUDO=$(which sudo)
SYSTEMCTL=$(which systemctl)

if [ -z ${RPM} -o -z ${SUDO} -o -z ${SYSTEMCTL} ] ; then
  echo "Can not find all tool needed for installation (rpm, sudo and systemctl)"
  exit 1
fi

main 
