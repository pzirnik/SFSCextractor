#
# Written by Ahmad Al Zayed - Feb 12, 2029
# Taken from Tami Instructions  
#

rpm -q inotify-tools 2> /dev/null 
[[ $? -eq 1 ]] && {
echo "Installing inotify-tools ..." 
sudo zypper install -y inotify-tools
} 

# check if file exist to not overwrite
# the user settings on update
if [ ! -f ~/.SFSCextractorrc ] ; then 
	echo "Creating ~/.SFSCextractorrc ..." 
	cat <<"EOF" > ~/.SFSCextractorrc 
# e.g. your browsers default download folder
DOWNLOAD_FOLDER=~/Downloads

# the folder with your cases
CASES_FOLDER=/$USER/SFSC 

# loglevel 1=errors 2=verbose
LOGLEVEL=1
EOF
fi

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
systemctl --user start SFSCextractor@$USER.service

echo "Let us check ..." 
systemctl --user status SFSCextractor@$USER.service
