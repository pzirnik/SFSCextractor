SFSCextractor will automaticaly create a case directory,
move the downloaded attachemnts into the case directory and try to
extract them. 
For this to work you need to preced the original filename with 

  "SFSC\<casnumber\>_" 

when downloading a attachment (in the download dialog of the browser).

e.g.

for SFSC case 0012345

  supportconfig_1234567891.tar.gz 

needs to be namend

  SFSC0012345_supportconfig_1234567891.tar.gz

There is a also a set of userscripts that help,
they in the js folder or you find them there:

https://greasyfork.org/en/users/438027-paul-zirnik

To install the SFSCextractor script you need to

1. make sure you have installed "inotify-tools" on the system

  sudo zypper in inotify-tools

2. copy/create the ~/.SFSCextractorrc file to your home directory
   the file should contain

-------~/.SFSCextractorrc--------------
```# the folder where you download the SFSC attachments
# e.g. your browsers default download folder
DOWNLOAD_FOLDER=~/Downloads

# the folder with your cases
CASES_FOLDER=/hdhome/SFSC 

# loglevel 1=errors 2=verbose
LOGLEVEL=1
```
---------------------------------------

3. copy the SFSCextractor.sh into bin/ of your home

```
  sudo cp SFSCextractor.sh /usr/bin/
  sudo chmod 755 /usr/bin/SFSCextractor.sh
```

4. copy the startscript to global systemd users directory

```
  sudo cp SFSCextractor@.service /usr/lib/systemd/user/
```

5. reload systemd at userspace

```
  systemctl --user daemon-reload
```

6. create a instance from the service for your user

```
  mkdir -p ~/.config/systemd/user
  systemctl --user enable SFSCextractor@$USER.service
```

7. start the service or relogin

```
  systemctl --user start SFSCextractor@$USER.service
```
