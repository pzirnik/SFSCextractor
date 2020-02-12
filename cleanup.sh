#
# Written by Ahmad Al Zayed - Feb 12, 2029
# Taken from Tami Instructions1
#

systemctl --user stop SFSCextractor@$USER.service
systemctl --user disable SFSCextractor@$USER.service
systemctl --user daemon-reload

rm ~/.SFSCextractorrc
sudo rm /usr/bin/SFSCextractor.sh /etc/systemd/user/SFSCextractor@.service 
